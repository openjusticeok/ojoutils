test_that("limit works with local tibble", {
  df <- tibble::tibble(x = 1:10)
  expect_equal(
    df |>
        limit(n = 5),
    tibble::tibble(x = 1:5)
  )
})