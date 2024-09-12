#' @title Describe Change
#'
#' @description Generate descriptive statements about changes between two values.
#'
#' @param before The initial value to compare.
#' @param after The value to compare to the initial value.
#' @param input_unit One of "number", "percent", or "ratio".
#' @param output_unit One of "number", "percent", "times", or "points". "points"
#' may only be used when `input_unit` is "percent" or "ratio".
#' @param template A `{glue}` template for the string returned when there is a change.
#' @param direction_phrases A named vector with three items: "increase", "decrease", and "none",
#' used to customize either the default or custom template. No one likes to hear
#' the same thing over and over, after all.
#' @param include_values A logical value indicating whether to include `before` and `after`
#' in the change description string.
#'
#' @return A string describing the change between two values, optionally including
#' the values themselves.
#'
#' @examples
#'
#' # Basic usage with defaults
#' describe_change(
#'   before = 1,
#'   after = 0.5,
#'   input_unit = "ratio",
#'   output_unit = "percent",
#'   template = "{direction} {change} {unit}"
#' )
#' #> decreased by 50 percent
#'
#' # Using different phrasing for changes
#' describe_change(
#'   before = 33,
#'   after = 66,
#'   input_unit = "percent",
#'   output_unit = "percent",
#'   template = "{direction} {change} {unit}",
#'   direction_phrases = c(
#'     increase = "rose by",
#'     decrease = "fell by",
#'     none = "stagnated"
#'   )
#' )
#' #> rose by 100 percent
#'
#' # Customizing the template
#' describe_change(
#'   before = 10,
#'   after = 12,
#'   input_unit = "number",
#'   output_unit = "number",
#'   template = "{direction} {change} people"
#' )
#' #> increased by 2 people
#'
describe_change <- function(
  before,
  after,
  input_unit,
  output_unit,
  template = "{direction} {change} {unit}",
  direction_phrases = c(
    increase = "increased by",
    decrease = "decreased by",
    none = "remained unchanged"
  ),
  include_values = FALSE
) {
  # Check inputs
  if (!is.numeric(before) || !is.numeric(after)) {
    rlang::abort("Both 'before' and 'after' must be numeric.")
  }

  # Validate input_unit and output_unit
  input_unit <- rlang::arg_match(
    input_unit,
    values = c(
      "number",
      "percent",
      "ratio"
    )
  )

  output_unit <- rlang::arg_match(
    output_unit,
    values = c(
      "number",
      "percent",
      "points",
      "times"
    )
  )

  # Calculate change and apply absolute flag if needed
  change <- after - before
  abs_change <- abs(change)

  # Determine direction (but not for unchanged case)
  direction <- dplyr::case_when(
    change > 0 ~ direction_phrases["increase"],
    change < 0 ~ direction_phrases["decrease"],
    TRUE ~ ""
  )

  # Handle unchanged case early
  if (change == 0) {
    return(glue::glue(direction_phrases["none"])) # Making a glue object so it inherits the same print method as the glue template
  }

  # Convert change_value based on input/output units
  change_value <- dplyr::case_when(
    output_unit == "points" & input_unit == "percent" ~ abs_change,
    output_unit == "percent" ~ (abs_change / before) * 100,
    output_unit == "times" ~ abs(after / before),
    output_unit == "number" ~ abs_change,
    TRUE ~ NA_integer_
  )

  if (is.na(change_value)) {
    rlang::abort(glue::glue("This error should not be reachable. Please report a bug for output unit: {output_unit}", output_unit))
  }

  # Handle the correct unit label for percentage points
  unit <- dplyr::case_when(
    output_unit == "points" ~ "percentage points",
    output_unit == "percent" ~ "percent",
    output_unit == "times" ~ "times",
    TRUE ~ output_unit
  )

  # Construct the description
  description <- glue::glue(
    template,
    direction = direction,
    change = change_value,
    unit = unit
  )

  return(description)
}
