test_that("Basic describe_change works with defaults", {
  expect_equal(
    describe_change(
      before = 1,
      after = 0.5,
      input_unit = "ratio",
      output_unit = "percent"
    ),
    "decreased by 50 percent"
  )
})

test_that("Custom direction phrases are used correctly", {
  expect_equal(
    describe_change(
      before = 33,
      after = 66,
      input_unit = "percent",
      output_unit = "percent",
      direction_phrases = c(
        increase = "rose by",
        decrease = "fell by",
        none = "stagnated"
      )
    ),
    "rose by 100 percent"
  )
})

test_that("Unchanged values are handled correctly", {
  expect_equal(
    describe_change(
      before = 50,
      after = 50,
      input_unit = "number",
      output_unit = "number"
    ),
    "remained unchanged"
  )
  expect_equal(
    describe_change(
      before = 50,
      after = 50,
      input_unit = "number",
      output_unit = "number",
      include_values = TRUE
    ),
    "remained unchanged at 50"
  )
})

test_that("Custom template works as expected", {
  expect_equal(
    describe_change(
      before = 10,
      after = 12,
      input_unit = "number",
      output_unit = "number",
      template = "{direction} {change} people"
    ),
    "increased by 2 people"
  )

  # TODO: Implement pluralization in template argument
  expect_equal(
    describe_change(
      before = 10,
      after = 11,
      input_unit = "number",
      output_unit = "number",
      template = "{direction} {change} people"
    ),
    "increased by 1 people"
  )

})

test_that("Handling ratio to points conversion", {
  expect_equal(
    describe_change(
      before = 1.2,
      after = 1.5,
      input_unit = "ratio",
      output_unit = "points"
    ),
    "increased by 30 percentage points"
  )
})

test_that("Handling number to times conversion", {
  expect_equal(
    describe_change(
      before = 5,
      after = 15,
      input_unit = "number",
      output_unit = "times"
    ),
    "increased by 3 times"
  )

  # TODO: Handle doubling or other special cases
  expect_equal(
    describe_change(
      before = 5,
      after = 10,
      input_unit = "number",
      output_unit = "times"
    ),
    "increased by 2 times"
  )

})

test_that("Error is raised for zero values", {
  expect_error(
    describe_change(
      before = 0,
      after = 2,
      input_unit = "number",
      output_unit = "percent"
    )
  )
  expect_error(
    describe_change(
      before = 2,
      after = 0,
      input_unit = "number",
      output_unit = "percent"
    )
  )
})

test_that("Error is raised for invalid unit conversion", {
  expect_error(
    describe_change(
      before = 10,
      after = 15,
      input_unit = "number",
      output_unit = "points"
    )
  )
})
