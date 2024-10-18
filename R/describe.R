#' @title Describe Change
#'
#' @description Generate descriptive statements about changes between two values.
#'
#' @param before The initial numeric value to compare. For some unit combinations `before` must be non-zero to avoid divide-by-zero errors.
#' @param after The numeric value to compare to the initial value.
#' @param input_unit One of "number", "percent", or "ratio". Determines how the `before` and `after` values are treated.
#' @param output_unit One of "number", "percent", "times", or "points". "points" may only be used when `input_unit` is "percent" or "ratio".
#' @param template A `{glue}` template for the string returned when there is a change. Defaults are provided based on `output_unit`. Possible template variables are: `direction`, `change`, and `unit`.
#' @param direction_phrases A named vector with three items: "increase", "decrease", and "none",
#' used to customize either the default or custom template.
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
#' )
#' #> decreased by 50 percent
#'
#' # Using different phrasing for changes
#' describe_change(
#'   before = 33,
#'   after = 66,
#'   input_unit = "percent",
#'   output_unit = "percent",
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
#' @export
#'
describe_change <- function(
    before,
    after,
    input_unit,
    output_unit,
    template = NULL,
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

  # Don't allow include values to be TRUE if template is supplied
  if (!is.null(template) && include_values) {
    rlang::abort("`include_values` must be 'FALSE' if you provide your own template. You can append the values in your custom template.")
  }

  if (!is.character(direction_phrases) || length(direction_phrases) != 3 ||
      !all(c("increase", "decrease", "none") %in% names(direction_phrases))) {
    rlang::abort("'direction_phrases' must be a named character vector with 'increase', 'decrease', and 'none' elements.")
  }

  # Validate input_unit and output_unit
  input_unit <- rlang::arg_match(
    input_unit,
    values = c("number", "percent", "ratio")
  )

  output_unit <- rlang::arg_match(
    output_unit,
    values = c("number", "percent", "points", "times")
  )

  # Make sure 'before' is positive for certain input/output unit combinations
  invalid_before_unit_combination <- dplyr::case_when(
    input_unit == "number" && output_unit == "percent" && before == 0 ~ TRUE,
    input_unit == "number" && output_unit == "times" && before == 0 ~ TRUE,
    input_unit == "percent" && output_unit == "percent" && before == 0 ~ TRUE,
    input_unit == "percent" && output_unit == "times" && before == 0 ~ TRUE,
    input_unit == "ratio" && output_unit == "percent" && before == 0 ~ TRUE,
    input_unit == "ratio" && output_unit == "times" && before == 0 ~ TRUE,
    TRUE ~ FALSE
  )

  if (invalid_before_unit_combination) {
    rlang::abort("'before' cannot be zero for the given input/output unit combination.")
  }

  # Calculate change and absolute change
  change <- after - before
  abs_change <- abs(change)

  # Determine direction (but not for unchanged case)
  direction <- dplyr::case_when(
    change > 0 ~ direction_phrases["increase"],
    change < 0 ~ direction_phrases["decrease"],
    TRUE ~ NA_character_
  )

  # Handle unchanged case early
  if (change == 0) {
    if (include_values) {
      return(glue::glue("{direction_phrases['none']} at {before}"))
    }
    return(glue::glue(direction_phrases["none"]))
  }

  # Convert change_value based on input/output units
  change_value <- dplyr::case_when(
    input_unit == "number" && output_unit == "number" ~ abs_change,
    input_unit == "number" && output_unit == "percent" ~ (abs_change / before) * 100,
    input_unit == "number" && output_unit == "points" ~ NA_real_,
    input_unit == "number" && output_unit == "times" ~ abs(after / before),
    input_unit == "percent" && output_unit == "number" ~ NA_real_,
    input_unit == "percent" && output_unit == "percent" ~ (abs_change / before) * 100,
    input_unit == "percent" && output_unit == "points" ~ abs_change,
    input_unit == "percent" && output_unit == "times" ~ after / before,
    input_unit == "ratio" && output_unit == "number" ~ NA_real_,
    input_unit == "ratio" && output_unit == "percent" ~ (abs_change / before) * 100,
    input_unit == "ratio" && output_unit == "points" ~ abs_change * 100,
    input_unit == "ratio" && output_unit == "times" ~ abs(after / before),
    TRUE ~ NA_real_
  )

  if (is.na(change_value)) {
    rlang::abort(glue::glue("Cannot convert from {input_unit} to {output_unit}"))
  }

  # Use cli's built-in pluralization
  unit <- dplyr::case_when(
    output_unit == "points" ~ cli::pluralize("{cli::qty(change_value)}percentage point{?s}"),
    TRUE ~ output_unit
  )

  if (is.null(template)) {
    template <- dplyr::if_else(
      output_unit == "number",
      "{direction} {change}",
      "{direction} {change} {unit}"
    )
  }

  # Construct the description with glue's pluralization
  description <- cli::pluralize(
    template,
    direction = direction,
    change = round(change_value, 2),
    unit = glue::glue(unit)
  )

  # Include values if required
  if (include_values) {
    description <- dplyr::if_else(
      output_unit == "number",
      glue::glue("{description}, from {before} to {after}"),
      glue::glue("{description}, from {before} to {after} {unit}")
    )
  }

  return(description)
}
