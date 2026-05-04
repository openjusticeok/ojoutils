# Function to use the OKPolicy quarto website template

Wrapper for `quarto use template` command. Creates a new project
directory and installs a Quarto template. The project name is derived
from the last component of the path and must be in kebab-case format.

## Usage

``` r
ojo_use_template(
  path = NULL,
  template = c("website", "report"),
  .interactive = rlang::is_interactive()
)
```

## Arguments

- path:

  Character. The path to the project directory. Can be absolute or
  relative to the current working directory. The last component of the
  path will be used as the project name and must be in kebab-case
  (lowercase letters, numbers, and hyphens only). If `NULL` (default)
  and in interactive mode, prompts for project name and location.

- template:

  Character. The type of project template to use. Must be one of:

  - `"website"` (default) - Multi-page website template

  - `"report"` - Single-page report template

- .interactive:

  Logical. Whether to prompt for user confirmation in interactive mode.
  Defaults to
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html).

## Value

Invisibly returns the result of the quarto command execution.

## Examples

``` r
if (FALSE) { # \dontrun{
# Interactive mode (prompts for project name and location)
ojo_use_template()

# Create a new website project (default)
ojo_use_template("my-new-website")

# Create a report project
ojo_use_template("my-new-report", template = "report")

# Create a project in a specific directory
ojo_use_template("~/Documents/Reports/my-new-website")

# Create a project with interactive turned off
ojo_use_template("my-new-website", .interactive = FALSE)
} # }
```
