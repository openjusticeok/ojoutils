#' @title Describe Change
#'
#' @description Generate descriptive statements about changes between two values.
describe_change <- function(
  before,
  after,
  input_unit,
  output_unit,
  absolute = FALSE,
  glue_template = "{direction} {change} {unit}",
  unchanged_template = "remained unchanged"
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
  abs_change <- dplyr::if_else(absolute, abs(change), change)

  # Determine direction (but not for unchanged case)
  direction <- dplyr::case_when(
    change > 0 ~ "increased by",
    change < 0 ~ "decreased by",
    TRUE ~ ""
  )

  # Handle unchanged case early
  if (change == 0) {
    return(glue::glue(unchanged_template)) # Making a glue object so it inherits the same print method as the glue template
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
    glue_template,
    direction = direction,
    change = change_value,
    unit = unit
  )

  return(description)
}
