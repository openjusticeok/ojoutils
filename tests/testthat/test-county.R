test_that("county parsing works", {
  test_strings <- c(
    "Tulsa County",
    "Rogermills, County",
    "Potato",
    "ROGER MILLS COUNTY"
  )

  expected_results <- c(
    "tulsa",
    "rogermills",
    NA_character_,
    "rogermills"
  )

  expect_equal(
    ojo_parse_county(test_strings),
    expected_results
  )

  expect_equal(
    ojo_parse_county(test_strings, case = "upper"),
    stringr::str_to_upper(expected_results)
  )

  expect_equal(
    ojo_parse_county(test_strings, case = "title"),
    c("Tulsa", "Roger Mills", NA_character_, "Roger Mills")
  )

  expect_equal(
    ojo_parse_county("MCCLAIN", case = "title"),
    "McClain"
  )

  expect_equal(
    ojo_parse_county("rogermills", case = "title", squish = T),
    "RogerMills"
  )
})
