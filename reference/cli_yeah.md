# Ask for Yes/No Confirmation

Interactive yes/no confirmation with cli styling. Returns TRUE for yes,
FALSE for no. Follows the pattern from cli issue \#488.

## Usage

``` r
cli_yeah(
  text,
  yes = c("Yes", "yeah"),
  no = c("No", "nope"),
  n_yes = 1,
  n_no = 1,
  shuffle = TRUE,
  ...,
  .envir = parent.frame()
)
```

## Arguments

- text:

  The question text (supports cli styling)

- yes:

  Character vector of affirmative options (default: c("Yes", "yeah"))

- no:

  Character vector of negative options (default: c("No", "nope"))

- n_yes:

  Number of yes options to show (default: 1)

- n_no:

  Number of no options to show (default: 1)

- shuffle:

  Whether to shuffle the options (default: TRUE)

- ...:

  Additional arguments passed to cli::cli_alert()

- .envir:

  Environment for glue interpolation

## Value

Logical TRUE for yes, FALSE for no

## Examples

``` r
if (FALSE) { # \dontrun{
# Simple confirmation
if (cli_yeah("Delete all files?")) {
  # Proceed with deletion
}

# Custom options
proceed <- cli_yeah(
  "Continue with migration?",
  yes = c("Yes, proceed", "Continue"),
  no = c("Cancel", "Stop")
)
} # }
```
