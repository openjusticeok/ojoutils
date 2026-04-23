# Parse Oklahoma Counties

Parse Oklahoma Counties

## Usage

``` r
ojo_parse_county(
  county,
  ...,
  case = "lower",
  squish = NULL,
  suffix = NULL,
  counties = ojo_counties,
  .silent = FALSE
)
```

## Arguments

- county:

  A string or character vector that represents an Oklahoma county

- ...:

  Placeholder for future arguments

- case:

  The case to format the county string to. One of "lower", "upper", or
  "title".

- squish:

  A boolean indicator of whether to remove whitespace

- suffix:

  Specification of a suffix to remove from each item in `county`. For
  example, " County, OK".

- counties:

  A vector of valid county names to match on.

- .silent:

  A currently unused argument.
