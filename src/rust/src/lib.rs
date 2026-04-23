use arrow::array::{Array, ArrayRef, Int32Array, Int64Array, RecordBatchReader, UInt32Array};
use arrow::compute::{cast, concat, take};
use arrow::datatypes::{DataType, Field, Schema};
use arrow::error::ArrowError;
use arrow::ffi_stream::ArrowArrayStreamReader;
use arrow::record_batch::RecordBatch;
use arrow::row::{RowConverter, SortField};
use arrow_extendr::{FromArrowRobj, IntoArrowRobj};
use extendr_api::prelude::*;
use std::collections::{HashMap, HashSet};
use std::sync::Arc;

fn extract_columns_from_stream(
    mut reader: impl RecordBatchReader,
    start_col_name: &str,
    end_col_name: &str,
    end_plus_one_col_name: &str,
    group_col_names: &[&str],
) -> Result<(ArrayRef, ArrayRef, ArrayRef, Vec<ArrayRef>), ArrowError> {
    let schema = reader.schema();

    let start_idx = schema.index_of(start_col_name)?;
    let end_idx = schema.index_of(end_col_name)?;
    let end_plus_one_idx = schema.index_of(end_plus_one_col_name)?;

    let group_idxs: Vec<usize> = group_col_names
        .iter()
        .map(|name| schema.index_of(name))
        .collect::<Result<_, ArrowError>>()?;

    let init_state = (
        Vec::new(),
        Vec::new(),
        Vec::new(),
        vec![Vec::new(); group_col_names.len()],
    );

    let (start_chunks, end_chunks, end_plus_one_chunks, group_chunks) = reader.try_fold(
        init_state,
        |(mut starts, mut ends, mut ends_plus_one, mut groups),
         batch_result|
         -> Result<_, ArrowError> {
            let batch = batch_result?;
            starts.push(batch.column(start_idx).clone());
            ends.push(batch.column(end_idx).clone());
            ends_plus_one.push(batch.column(end_plus_one_idx).clone());

            groups
                .iter_mut()
                .zip(&group_idxs)
                .for_each(|(bucket, &idx)| {
                    bucket.push(batch.column(idx).clone());
                });

            Ok((starts, ends, ends_plus_one, groups))
        },
    )?;

    let contiguous_start = concat(&start_chunks.iter().map(|a| a.as_ref()).collect::<Vec<_>>())?;

    let contiguous_end = concat(&end_chunks.iter().map(|a| a.as_ref()).collect::<Vec<_>>())?;

    let contiguous_end_plus_one = concat(
        &end_plus_one_chunks
            .iter()
            .map(|a| a.as_ref())
            .collect::<Vec<_>>(),
    )?;

    let contiguous_groups = group_chunks
        .into_iter()
        .map(|chunks| {
            let refs: Vec<&dyn Array> = chunks.iter().map(|a| a.as_ref()).collect();
            concat(&refs)
        })
        .collect::<Result<Vec<ArrayRef>, ArrowError>>()?;

    Ok((
        contiguous_start,
        contiguous_end,
        contiguous_end_plus_one,
        contiguous_groups,
    ))
}

fn densify_time_periods(
    starts: &ArrayRef,
    ends: &ArrayRef,
    ends_plus_one: &ArrayRef,
) -> Result<(Vec<usize>, Vec<usize>, ArrayRef), ArrowError> {
    let original_type = starts.data_type();

    let starts_casted = cast(starts, &DataType::Int64)?;
    let ends_casted = cast(ends, &DataType::Int64)?;
    let ends_plus_one_casted = cast(ends_plus_one, &DataType::Int64)?;

    let starts_i64 = starts_casted.as_any().downcast_ref::<Int64Array>().unwrap();
    let ends_i64 = ends_casted.as_any().downcast_ref::<Int64Array>().unwrap();
    let ends_plus_one_i64 = ends_plus_one_casted
        .as_any()
        .downcast_ref::<Int64Array>()
        .unwrap();

    let unique_vals_set: HashSet<i64> = starts_i64
        .iter()
        .chain(ends_i64.iter())
        .chain(ends_plus_one_i64.iter())
        .flatten()
        .collect();

    let mut sorted_unique_vals: Vec<i64> = unique_vals_set.into_iter().collect();
    sorted_unique_vals.sort_unstable();

    let val_to_idx: HashMap<i64, usize> = sorted_unique_vals
        .iter()
        .enumerate()
        .map(|(idx, &val)| (val, idx))
        .collect();

    let start_indices: Vec<usize> = starts_i64
        .iter()
        .map(|opt_val| {
            opt_val
                .and_then(|val| val_to_idx.get(&val).copied())
                .unwrap_or(usize::MAX)
        })
        .collect();

    let end_indices: Vec<usize> = ends_i64
        .iter()
        .map(|opt_val| {
            opt_val
                .and_then(|val| val_to_idx.get(&val).copied())
                .unwrap_or(usize::MAX)
        })
        .collect();

    let unique_i64_array = std::sync::Arc::new(Int64Array::from(sorted_unique_vals)) as ArrayRef;
    let unique_periods = cast(&unique_i64_array, original_type)?;

    Ok((start_indices, end_indices, unique_periods))
}

fn encode_group_ids(
    group_cols: &[ArrayRef],
    num_rows: usize,
) -> Result<(Vec<usize>, Vec<u32>, usize), ArrowError> {
    if group_cols.is_empty() {
        let group_ids = vec![0; num_rows];
        let first_occurrences = if num_rows > 0 { vec![0] } else { vec![] };
        let num_groups = if num_rows > 0 { 1 } else { 0 };
        return Ok((group_ids, first_occurrences, num_groups));
    }

    let sort_fields: Vec<SortField> = group_cols
        .iter()
        .map(|col| SortField::new(col.data_type().clone()))
        .collect();

    let converter = RowConverter::new(sort_fields)?;

    let rows = converter.convert_columns(group_cols)?;

    let mut first_occurrences = Vec::new();
    let mut group_map = HashMap::new();

    let group_ids: Vec<usize> = (0..num_rows)
        .map(|i| {
            let row_bytes = rows.row(i);

            *group_map.entry(row_bytes).or_insert_with(|| {
                let new_id = first_occurrences.len();
                first_occurrences.push(i as u32);
                new_id
            })
        })
        .collect();

    let num_groups = first_occurrences.len();

    Ok((group_ids, first_occurrences, num_groups))
}

fn compute_difference_matrix(
    start_indices: &[usize],
    end_indices: &[usize],
    group_ids: &[usize],
    num_groups: usize,
    num_periods: usize,
    inclusive: &[bool],
) -> Vec<i32> {
    let start_incl = *inclusive.get(0).unwrap();
    let end_incl = *inclusive.get(1).unwrap();

    let mut matrix = vec![0; num_groups * num_periods];

    // Boundary Pass
    start_indices
        .iter()
        .zip(end_indices.iter())
        .zip(group_ids.iter())
        .for_each(|((&start_idx, &end_idx), &group_id)| {
            let base_idx = group_id * num_periods;

            // Handle the start boundary (+1)
            // usize::MAX is our sentinel for an R `NA` value
            if start_idx != usize::MAX {
                let s_idx = if start_incl { start_idx } else { start_idx + 1 };
                if s_idx < num_periods {
                    matrix[base_idx + s_idx] += 1;
                }
            }

            // Handle the end boundary (-1)
            if end_idx != usize::MAX {
                let e_idx = if end_incl { end_idx + 1 } else { end_idx };
                if e_idx < num_periods {
                    matrix[base_idx + e_idx] -= 1;
                }
            }
        });

    // Cumulative Sum Pass
    matrix.chunks_exact_mut(num_periods).for_each(|group_row| {
        let mut running_sum = 0;

        group_row.iter_mut().for_each(|cell| {
            running_sum += *cell;
            *cell = running_sum;
        });
    });

    matrix
}

fn assemble_arrow_columns(
    matrix: Vec<i32>,
    num_periods: usize,
    num_groups: usize,
    first_occurrences: &[u32],
    group_cols: &[ArrayRef],
    unique_periods: &ArrayRef,
) -> Result<(ArrayRef, ArrayRef, Vec<ArrayRef>), ArrowError> {
    let final_counts = Arc::new(Int32Array::from(matrix)) as ArrayRef;

    let date_indices: UInt32Array = (0..num_groups)
        .flat_map(|_| 0..(num_periods as u32))
        .collect();

    let final_dates = take(unique_periods, &date_indices, None)?;

    let group_indices: UInt32Array = first_occurrences
        .iter()
        .flat_map(|&idx| std::iter::repeat(idx).take(num_periods))
        .collect();

    let final_groups: Result<Vec<ArrayRef>, ArrowError> = group_cols
        .iter()
        .map(|col| take(col, &group_indices, None))
        .collect();

    Ok((final_dates, final_counts, final_groups?))
}

fn export_results(
    date_array: ArrayRef,
    date_name: &str,
    count_array: ArrayRef,
    count_name: &str,
    group_arrays: Vec<ArrayRef>,
    group_names: &[&str],
) -> Result<Robj, extendr_api::Error> {
    let groups_iter = group_arrays
        .into_iter()
        .zip(group_names)
        .map(|(arr, &name)| {
            let field = Field::new(name, arr.data_type().clone(), true);
            (field, arr)
        });

    let date_iter = std::iter::once({
        let field = Field::new(date_name, date_array.data_type().clone(), true);
        (field, date_array)
    });

    let count_iter = std::iter::once({
        let field = Field::new(count_name, count_array.data_type().clone(), false);
        (field, count_array)
    });

    let (fields, columns): (Vec<Field>, Vec<ArrayRef>) =
        date_iter.chain(count_iter).chain(groups_iter).unzip();

    let schema = Arc::new(Schema::new(fields));

    let batch = RecordBatch::try_new(schema, columns).unwrap();

    batch.into_arrow_robj()
}

#[extendr]
fn count_interval_(
    stream: Robj,
    start: String,
    end: String,
    end_plus_one: String,
    date_name: String,
    count_name: String,
    by: Vec<String>,
    inclusive: Logicals,
) -> Result<Robj, extendr_api::Error> {
    let reader = match ArrowArrayStreamReader::from_arrow_robj(&stream) {
        Ok(r) => r,
        Err(e) => {
            throw_r_error(format!("Failed to create Arrow stream reader: {}", e));
        }
    };

    let group_cols_str: Vec<&str> = by.iter().map(|s| s.as_str()).collect();

    let (starts, ends, ends_plus_one, groups) =
        extract_columns_from_stream(reader, &start, &end, &end_plus_one, &group_cols_str)
            .expect("Stream extraction failed");

    let num_rows = starts.len();

    let (start_idx, end_idx, unique_periods) =
        densify_time_periods(&starts, &ends, &ends_plus_one).unwrap();
    let num_periods = unique_periods.len();

    let (group_ids, first_occurrences, num_groups) = encode_group_ids(&groups, num_rows).unwrap();

    let inclusive_bools: Vec<bool> = inclusive.iter().map(|v| v.is_true()).collect();

    let matrix = compute_difference_matrix(
        &start_idx,
        &end_idx,
        &group_ids,
        num_groups,
        num_periods,
        &inclusive_bools,
    );

    let (final_dates, final_counts, final_groups) = assemble_arrow_columns(
        matrix,
        num_periods,
        num_groups,
        &first_occurrences,
        &groups,
        &unique_periods,
    )
    .unwrap();

    export_results(
        final_dates,
        &date_name,
        final_counts,
        &count_name,
        final_groups,
        &group_cols_str,
    )
}

// Macro to generate exports.
extendr_module! {
    mod ojoutils;
    fn count_interval_;
}
