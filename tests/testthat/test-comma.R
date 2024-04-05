test_that("comma works", {
  x <- 1234567.89
  expect_equal(
    comma(x),
    "1,234,568"
  )
  expect_equal(
    comma(x, digits = 3),
    "1,234,567.890"
  )
  expect_equal(
    comma(x, digits = 3, drop_trailing_zeros = TRUE),
    "1,234,567.89"
  )
  y <- 0.4
  expect_equal(
    comma(y),
    "0.4"
  )
  expect_equal(
    comma(y, round_to_zero = TRUE),
    "0"
  )
})
