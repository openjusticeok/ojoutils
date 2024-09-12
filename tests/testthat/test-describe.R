testthat::test_that(
  "describe_change works with percentage input and percentage points output",
  {
    res <- describe_change(
      before = 25,
      after = 75,
      input_unit = "percent",
      output_unit = "points"
    )
    
    testthat::expect_equal(res, "increased by 50 percentage points")
  }
)
