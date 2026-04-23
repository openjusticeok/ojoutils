# Describe Change

Generate descriptive statements about changes between two values.

## Usage

``` r
describe_change(
  before,
  after,
  input_unit,
  output_unit,
  template = NULL,
  direction_phrases = c(increase = "increased by", decrease = "decreased by", none =
    "remained unchanged"),
  include_values = FALSE
)
```

## Arguments

- before:

  The initial numeric value to compare. For some unit combinations
  `before` must be non-zero to avoid divide-by-zero errors.

- after:

  The numeric value to compare to the initial value.

- input_unit:

  One of "number", "percent", or "ratio". Determines how the `before`
  and `after` values are treated.

- output_unit:

  One of "number", "percent", "times", or "points". "points" may only be
  used when `input_unit` is "percent" or "ratio".

- template:

  A `{glue}` template for the string returned when there is a change.
  Defaults are provided based on `output_unit`. Possible template
  variables are: `direction`, `change`, and `unit`.

- direction_phrases:

  A named vector with three items: "increase", "decrease", and "none",
  used to customize either the default or custom template.

- include_values:

  A logical value indicating whether to include `before` and `after` in
  the change description string.

## Value

A string describing the change between two values, optionally including
the values themselves.

## Examples

``` r
# Basic usage with defaults
describe_change(
  before = 1,
  after = 0.5,
  input_unit = "ratio",
  output_unit = "percent",
)
#> decreased by 50 percent
#> decreased by 50 percent

# Using different phrasing for changes
describe_change(
  before = 33,
  after = 66,
  input_unit = "percent",
  output_unit = "percent",
  direction_phrases = c(
    increase = "rose by",
    decrease = "fell by",
    none = "stagnated"
  )
)
#> rose by 100 percent
#> rose by 100 percent

# Customizing the template
describe_change(
  before = 10,
  after = 12,
  input_unit = "number",
  output_unit = "number",
  template = "{direction} {change} people"
)
#> increased by 2 people
#> increased by 2 people
```
