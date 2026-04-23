# Create Project

Creates a new R project with a standard directory structure

## Usage

``` r
ojo_create_project(
  name = NULL,
  description = NULL,
  dir = ".",
  private = TRUE,
  packages = NULL
)
```

## Arguments

- name:

  Character string. Name of the project/repo. If `NULL`, will attempt
  interactive prompt.

- description:

  Character string. Description of the project for GitHub.

- dir:

  Character string. Directory where project should be created. Defaults
  to current working directory.

- private:

  Logical. Whether the GitHub repository should be private. Defaults to
  `TRUE`.

- packages:

  Character vector. Additional packages to install in the project's renv
  environment. Currently not implemented.

## Value

Invisible path to the created project directory.

## Getting Started

To learn more about creating projects, see the vignette:
`vignette("project-creation", package = "ojotools")`

## Examples

``` r
if (FALSE) { # \dontrun{
ojo_create_project("my-analysis", "Analysis of court data")
} # }
```
