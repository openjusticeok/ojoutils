#' @title Convert a decimal to a percentage as a formatted string
#' @description User inputs a decimal number and functions converts it to a percentage as a formatted string.
#' @param x A numeric value to be converted to a percentage
#' @param digits Number of decimal places to round to, Default: 0
#' @param abs Take the absolute value of x before converting to a percentage, Default: FALSE
#' @param drop_trailing_zeros Drop trailing zeros after the decimal point, Default: FALSE
#' @param multiply_by_100 Multiply x by 100 before converting to a percentage, Default: TRUE
#' @param ... Additional arguments to be passed to the `formatC` function
#' @return A formatted string representing the percentage
#' @details The function uses the `round_half_up` function from the janitor package to round the number to the specified number of decimal places. The `formatC` function is then used to format the number as a percentage with the specified number of decimal places and trailing zeros.
#' @examples
#' x <- 0.1235
#' x
#' percent(x)
#' percent(x, digits = 3)
#' percent(x, digits = 3, drop_trailing_zeros = FALSE)
#' @seealso
#'  \code{\link[janitor]{round_half_up}}
#'  \code{\link[base]{formatC}}
#' @rdname percent
#' @export
#' @author Anthony Flores
#' @importFrom janitor round_half_up
percent <- function(x,
                    digits = 0,
                    abs = FALSE,
                    drop_trailing_zeros = FALSE,
                    multiply_by_100 = TRUE,
                    ...
) {

  .digits <- digits

  if (abs) { x <- abs(x) }
  if (multiply_by_100) { x <- 100 * x }

  x <- janitor::round_half_up(x, digits = .digits)
  x <-
    formatC(
      x,
      big.mark = ",",
      format = "f",
      digits = .digits,
      drop0trailing = drop_trailing_zeros,
      ...
    ) |>
    paste0("%")

  return(x)
}
