# Limit

A thin wrapper around [`head`](https://rdrr.io/r/utils/head.html) to
sooth the pain of context switching between R and SQL

## Usage

``` r
limit(x, ...)
```

## Arguments

- x:

  The object to limit

- ...:

  Additional arguments to [`head`](https://rdrr.io/r/utils/head.html)

## Value

The limited object

## Details

A thin wrapper around [`head`](https://rdrr.io/r/utils/head.html) that
allows `limit` to be used in place of `head`. This is useful because
sometimes it is hard to context switch between R and SQL. It can be used
on lazy data frames since this package imports `dbplyr`.
