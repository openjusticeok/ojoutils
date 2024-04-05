## Compares the formatting functions of the `ojoutils`, `scales`, and `gt` packages.
  ## Specifically, the syntax required to get equivalent outputs.

x <- 1234567890.125

# No decimals
ojoutils::comma(x)
scales::comma(x)
gt::vec_fmt_number(x, 0)
gt::vec_fmt_integer(x) # Alternative

# Round-half-even (banker's rounding)
ojoutils::comma(x, 2, round_half_up = FALSE)
scales::comma(x, 0.01)
gt::vec_fmt_number(x)

# Round-half-up (arithmetic rounding)
ojoutils::comma(x, 2)
scales::comma(x |> janitor::round_half_up(2), 0.01)
gt::vec_fmt_number(x |> janitor::round_half_up(2), 2)

# Absolute Value (only ojoutils)
ojoutils::comma(-x, 2, abs = TRUE)

# TODO: Round to millions
ojoutils::comma(x)
scales::comma(x, 0.1, 1e-6, suffix = "M")
gt::vec_fmt_number(x, 1, suffixing = c(NA, "M", NA, NA))

# TODO: Dynamic Suffix (only ojoutils and gt)
gt::vec_fmt_number(x, suffixing = TRUE)
gt::vec_fmt_number(x / 1000, suffixing = TRUE)

# TODO: Conditional Suffix/Prefix (only ojoutils, can wait to implement)
ojoutils::comma(x, 2, abs = TRUE)

# Significant figures
ojoutils::comma(signif(x, 3))
scales::comma(signif(x, 3))
gt::vec_fmt_number(x, n_sigfig = 3)

# TODO: Formatting Pattern (can wait to implement)
gt::vec_fmt_number(x, pattern = "WOW: {x}!!")

y <- c(1000.15, -1000.15)

# TODO: +/- signs (can wait to implement)
ojoutils::comma(y)
scales::comma(y, style_positive = "plus")
gt::vec_fmt_number(y, 0, force_sign = TRUE)

# TODO: Accounting format (can wait)
ojoutils::comma(-y, 2)
scales::comma(-y |> janitor::round_half_up(2), 0.01, style_negative = "parens")
gt::vec_fmt_number(-y |> janitor::round_half_up(2), accounting = TRUE)

z <- 12.15

# Don't drop trailing zeros
ojoutils::comma(z, 3)
scales::comma(z, 0.001)
gt::vec_fmt_number(z, 3)

# Drop trailing zeros
ojoutils::comma(z, 3, drop_trailing_zeros = TRUE)
scales::comma(z, 0.001, drop0trailing = TRUE)
gt::vec_fmt_number(z, 3, drop_trailing_zeros = TRUE)

