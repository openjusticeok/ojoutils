
# ojoutils

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

`ojoutils` is an R package with a collection of lightweight convenience functions
for speeding up common data analysis tasks.

## Installation

You can install the development version of ojoutils from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("openjusticeok/ojoutils")
```

## Functions

The package includes the following functions:
- `ojo_parse_county` function for standardizing Oklahoma county names, optionally specifying the case of the result.
- `ojo_use_template` function to make it easier to add a new blank Quarto report to a project repository.
- `dir_empty` function to easily check whether a directory is empty.
- `comma` and `percent` functions to format numbers as strings with commas and percentages, respectively.
- `limit` function which works like `head` but is helpful for when your brain is in SQL mode.
