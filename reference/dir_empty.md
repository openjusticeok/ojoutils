# Directory Empty?

Takes a path and determines whether it is empty.

## Usage

``` r
dir_empty(path)
```

## Arguments

- path:

  A relative or absolute path to the directory to test.

## Value

`TRUE` if the directory is empty, otherwise `FALSE`. If the directory
doesn't exist, or the string supplied to `path` isn't recognized as a
valid path, then the function returns an error.
