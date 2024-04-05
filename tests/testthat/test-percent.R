test_that("percent works", {
  x <- 0.1235
  expect_equal(percent(x), "12%")
  expect_equal(percent(x, digits = 3), "12.350%")
  expect_equal(percent(x, digits = 3, drop_trailing_zeros = TRUE), "12.35%")
})
