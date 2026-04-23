#' Count intervals over time periods
#'
#' @description
#' Counts the number of active intervals for each time period (day, hour, etc.)
#' given start and end dates. Useful for occupancy or population counts over time.
#'
#' @param data A data frame or Arrow table containing the interval data.
#' @param start Character string. Name of the column containing interval start dates.
#' @param end Character string. Name of the column containing interval end dates.
#' @param period Character string. Time period for counting (e.g., "day", "hour",
#'   "week", "month", "quarter", "year"). Defaults to "day".
#' @param date_name Character string. Name for the output date column.
#'   Defaults to "date".
#' @param count_name Character string. Name for the output count column.
#'   Defaults to "n".
#' @param .by Character vector. Column names to group by. Defaults to empty
#'   (no grouping).
#' @param .fill Named list with "start" and "end" elements. Values to use when
#'   filling NA start/end dates. If NULL (default), uses min/max of data.
#' @param .inclusive Logical vector of length 2. Whether start and end boundaries
#'   are inclusive. Defaults to `c(TRUE, TRUE)`.
#'
#' @return A tibble with columns for date, count, and any grouping variables.
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' df <- data.frame(
#'   start = as.Date(c("2024-01-01", "2024-01-05")),
#'   end = as.Date(c("2024-01-03", "2024-01-06"))
#' )
#' count_interval(df, start = "start", end = "end", period = "day")
#'
#' # With grouping
#' df <- data.frame(
#'   start = as.Date(c("2024-01-01", "2024-01-02")),
#'   end = as.Date(c("2024-01-03", "2024-01-04")),
#'   ward = c("A", "B")
#' )
#' count_interval(df, start = "start", end = "end", period = "day", .by = "ward")
#' }
#'
#' @importFrom rlang check_required abort sym syms has_name :=
#' @importFrom dplyr collect select mutate everything filter group_by ungroup
#' @importFrom dplyr all_of coalesce compute
#' @importFrom lubridate as_datetime floor_date period
#' @importFrom arrow as_arrow_table
#' @importFrom nanoarrow as_nanoarrow_array_stream
#' @importFrom tidyr complete fill
#' @export
count_interval <- function(
    data,
    start,
    end,
    period = "day",
    date_name = "date",
    count_name = "n",
    .by = character(),
    .fill = list(start = NULL, end = NULL),
    .inclusive = c(TRUE, TRUE)
) {
  rlang::check_required(data)
  rlang::check_required(start)
  rlang::check_required(end)

  if (is.null(data)) {
    rlang::abort("`data` must not be NULL.")
  }

  # Extract names for validation regardless of input type
  data_names <- if (inherits(data, "ArrowTabular")) {
    data$schema$names
  } else {
    names(data)
  }

  if (!start %in% data_names) {
    rlang::abort(paste0("Column '", start, "' not found in `data`."))
  }
  if (!end %in% data_names) {
    rlang::abort(paste0("Column '", end, "' not found in `data`."))
  }
  if (length(.by) > 0 && any(!.by %in% data_names)) {
    missing <- setdiff(.by, data_names)
    rlang::abort(paste0(
      "Columns not found in `data`: ", paste(missing, collapse = ", "), "."
    ))
  }
  if (date_name %in% c(start, end, count_name, .by)) {
    rlang::abort(
      "`date_name` must not match `start`, `end`, `count_name`, or any `.by` column."
    )
  }
  if (count_name %in% c(start, end, date_name, .by)) {
    rlang::abort(
      "`count_name` must not match `start`, `end`, `date_name`, or any `.by` column."
    )
  }
  if (any(.by %in% c(start, end))) {
    rlang::abort("`.by` columns must not include `start` or `end`.")
  }

  if (!is.character(period) || length(period) != 1L || is.na(period)) {
    rlang::abort("`period` must be a single non-NA character string.")
  }

  period_seq <- sub("minute", "min", period, fixed = TRUE)
  period_seq <- sub("second", "sec", period_seq, fixed = TRUE)

  if (
    !is.list(.fill) ||
      length(.fill) != 2L ||
      !all(rlang::has_name(.fill, c("start", "end")))
  ) {
    rlang::abort(
      "`.fill` must be a named list with 'start' and 'end' elements."
    )
  }

  if (length(.inclusive) != 2L || !is.logical(.inclusive)) {
    rlang::abort("`.inclusive` must be a length-2 logical vector.")
  }

  # Convert to arrow for processing
  data <- arrow::as_arrow_table(data)
  
  if (nrow(data) == 0) {
    empty_res <- data |>
      dplyr::collect() |>
      dplyr::select(dplyr::all_of(.by)) |>
      dplyr::mutate(
        !!rlang::sym(date_name) := lubridate::as_datetime(character()),
        !!rlang::sym(count_name) := integer()
      ) |>
      dplyr::select(!!rlang::sym(date_name), !!rlang::sym(count_name), dplyr::everything())
    return(empty_res)
  }
  
  schema <- data$schema
  start_type <- schema$GetFieldByName(start)$type
  end_type <- schema$GetFieldByName(end)$type

  # Compute fill defaults from data min/max when NULL
  if (is.null(.fill$start)) {
    start_vals <- data[[start]]$as_vector()
    if (all(is.na(start_vals))) {
      rlang::abort(
        "All values in 'start' are NA and no `.fill$start` was provided."
      )
    }
    fill_start <- lubridate::as_datetime(min(start_vals, na.rm = TRUE))
  } else {
    fill_start <- lubridate::as_datetime(.fill$start)
  }

  if (is.null(.fill$end)) {
    end_vals <- data[[end]]$as_vector()
    if (all(is.na(end_vals))) {
      rlang::abort(
        "All values in 'end' are NA and no `.fill$end` was provided."
      )
    }
    fill_end <- lubridate::as_datetime(max(end_vals, na.rm = TRUE))
  } else {
    fill_end <- lubridate::as_datetime(.fill$end)
  }

  query <- data |>
    dplyr::mutate(
      !!rlang::sym(start) := lubridate::floor_date(
        dplyr::coalesce(
          !!rlang::sym(start),
          arrow::as_arrow_array(fill_start)$cast(start_type)
        ),
        unit = period
      ),
      !!rlang::sym(end) := lubridate::floor_date(
        dplyr::coalesce(
          !!rlang::sym(end),
          arrow::as_arrow_array(fill_end)$cast(end_type)
        ),
        unit = period
      )
    )

  tab <- dplyr::compute(query)

  end_vec <- tab[[end]]$as_vector()

  max_expected_date <- max(end_vec, na.rm = TRUE)

  tab$.end_plus_one <- end_vec + if (period == "quarter") {
    lubridate::period(3, units = "months")
  } else {
    lubridate::period(1, units = period)
  }

  stream <- nanoarrow::as_nanoarrow_array_stream(tab)

  res <- count_interval_(
    stream = stream,
    start = start,
    end = end,
    end_plus_one = ".end_plus_one",
    date_name = date_name,
    count_name = count_name,
    by = .by,
    inclusive = .inclusive
  ) |>
    arrow::as_arrow_table() |>
    dplyr::collect()

  if (nrow(res) == 0) {
    return(
      dplyr::select(
        res,
        !!rlang::sym(date_name),
        !!rlang::sym(count_name),
        !!!rlang::syms(.by)
      )
    )
  }

  res |>
    dplyr::group_by(!!!rlang::syms(.by)) |>
    tidyr::complete(
      !!rlang::sym(date_name) := seq(
        min(!!rlang::sym(date_name), na.rm = TRUE),
        max(!!rlang::sym(date_name), na.rm = TRUE),
        by = period_seq
      )
    ) |>
    tidyr::fill(!!rlang::sym(count_name), .direction = "down") |>
    dplyr::mutate(
      !!rlang::sym(count_name) := dplyr::coalesce(!!rlang::sym(count_name), 0L)
    ) |>
    dplyr::filter(!!rlang::sym(date_name) <= max_expected_date) |>
    dplyr::ungroup() |>
    dplyr::select(
      !!rlang::sym(date_name),
      !!rlang::sym(count_name),
      !!!rlang::syms(.by)
    )
}
