# Count intervals over time periods

Counts the number of active intervals for each time period (day, hour,
etc.) given start and end dates. Useful for occupancy or population
counts over time.

## Usage

``` r
count_interval(
  data,
  start,
  end,
  period = "day",
  date_name = "date",
  count_name = "n",
  .by = character(),
  .fill = list(start = NULL, end = NULL),
  .inclusive = c(TRUE, TRUE)
)
```

## Arguments

- data:

  A data frame or Arrow table containing the interval data.

- start:

  Character string. Name of the column containing interval start dates.

- end:

  Character string. Name of the column containing interval end dates.

- period:

  Character string. Time period for counting (e.g., "day", "hour",
  "week", "month", "quarter", "year"). Defaults to "day".

- date_name:

  Character string. Name for the output date column. Defaults to "date".

- count_name:

  Character string. Name for the output count column. Defaults to "n".

- .by:

  Character vector. Column names to group by. Defaults to empty (no
  grouping).

- .fill:

  Named list with "start" and "end" elements. Values to use when filling
  NA start/end dates. If NULL (default), uses min/max of data.

- .inclusive:

  Logical vector of length 2. Whether start and end boundaries are
  inclusive. Defaults to `c(TRUE, TRUE)`.

## Value

A tibble with columns for date, count, and any grouping variables.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage
df <- data.frame(
  start = as.Date(c("2024-01-01", "2024-01-05")),
  end = as.Date(c("2024-01-03", "2024-01-06"))
)
count_interval(df, start = "start", end = "end", period = "day")

# With grouping
df <- data.frame(
  start = as.Date(c("2024-01-01", "2024-01-02")),
  end = as.Date(c("2024-01-03", "2024-01-04")),
  ward = c("A", "B")
)
count_interval(df, start = "start", end = "end", period = "day", .by = "ward")
} # }
```
