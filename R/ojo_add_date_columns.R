#' @title Add Date Columns for Court Data
#'
#' @description
#' ojo_add_date_columns() is a helper function that adds year_filed and month_filed columns to the court data.
#'
#' @param data A dataframe containing court data
#'
#' @importFrom dplyr mutate
#' @importFrom lubridate floor_date as_date
#'
#' @export ojo_add_date_columns
#' @return A dataframe with year_filed and month_filed columns
#'
#' @examples
#' \dontrun{
#' data <- tibble::tibble(
#'   date_filed = as.Date(c("2021-01-01", "2021-02-01", "2021-03-01"))
#' )
#' data |>
#'   ojo_add_date_columns()
#' }
#'
ojo_add_date_columns <- function(data) {
  # Create Year and Month Filed Variables
  data <- data |>
    dplyr::mutate(
      year_filed = lubridate::floor_date(date_filed, "year") |> lubridate::as_date(),
      month_filed = lubridate::floor_date(date_filed, "month") |> lubridate::as_date()
    )

  return(data)
}
