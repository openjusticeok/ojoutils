#' @title Convert a numeric value to a formatted string with commas
#' @description User inputs a numeric value and function converts it to a formatted string with commas.
#' @param x A numeric value to be converted to a formatted string with commas
#' @param digits Number of decimal places to round to, Default:
#' @param abs Take the absolute value of x before converting to a formatted string with commas, Default: FALSE
#' @param round_to_zero Ensures no number every rounds to zero. For example, 0.4 will always be displayed as 0.4 and not be rounded to zero, but 1.4 will still round to 1. Default: TRUE
#' @param drop_trailing_zeros Drop trailing zeros after the decimal point, Default: FALSE
#' @return A formatted string with commas
#' @details The function uses the `round_half_up` function from the janitor package to round the number to the specified number of decimal places. The `formatC` function is then used to format the number as a string with commas and the specified number of decimal places and trailing zeros.
#'
#' @examples
#' x <- 1234567.89
#' x
#' comma(x)
#' comma(x, digits = 3)
#' comma(x, digits = 3, drop_trailing_zeros = TRUE)
#' y <- 0.4
#' comma(y)
#' comma(y, round_to_zero = TRUE)
#' @seealso
#'  \code{\link[janitor]{round_half_up}}
#'  \code{\link[base]{formatC}}
#' @rdname comma
#' @export
#' @author Anthony Flores
#' @importFrom janitor round_half_up
comma <- function(x,
                  digits = 0,
                  round_half_up = TRUE,
                  abs = FALSE,
                  drop_trailing_zeros = FALSE,
                  round_to_zero = TRUE,
                  ...
) {
  .digits <-  digits

  if (round_half_up == TRUE) {
    if (round_to_zero == TRUE) {
      x <- janitor::round_half_up(x, digits = .digits)
    } else {
      if (.digits == 0 & janitor::round_half_up(x, 0) == 0) {
        .digits <- 1
        x <- janitor::round_half_up(x, .digits)
      }
    }
  }

  # Take absolute value of x before formatting
  if (abs) {
    x <- abs(x)
  }

  x <-
    formatC(
      x,
      big.mark = ",",
      format = "f",
      digits = .digits,
      drop0trailing = drop_trailing_zeros,
      ...
    )

  return(x)

}
