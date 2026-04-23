# Function to use the OJO quarto HTML template

Wrapper for `quarto use template` command. Defaults to OJO html
template.

## Usage

``` r
ojo_use_template(path, template = "openjusticeok/ojo-report-template")
```

## Arguments

- path:

  The name of the directory where the template should be added. This
  should be a string representing an absolute path, or a path relative
  to the current working directory.

- template:

  The name of the Quarto template to use. This should be a string in the
  format "username/repository". Default is
  "openjusticeok/ojo-report-template".

## Value

This function does not return a value. If the user chooses not to
proceed with the operation, the function exits silently.

## Examples

``` r
if (FALSE) { # \dontrun{
ojo_use_template(template = "openjusticeok/ojo-report-template", path = "my_directory")
} # }
```
