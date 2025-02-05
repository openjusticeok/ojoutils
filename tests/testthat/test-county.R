test_that("county parsing works", {
  test_strings <- c(
    "Tulsa County",
    "Rogermills, County",
    "Potato",
    "ROGER MILLS COUNTY"
  )

  expected_results <- c(
    "tulsa",
    "roger mills",
    NA_character_,
    "roger mills"
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

test_that("ojo_list_counties works", {

  # Test normal version
  expect_equal(
    ojo_list_counties(case = "lower", squish = FALSE, suffix = NULL, oscn_only = FALSE)$value,
    c(
      "adair", "alfalfa", "atoka", "beaver", "beckham", "blaine", "bryan",
      "caddo", "canadian", "carter", "cherokee", "choctaw", "cimarron", "cleveland",
      "coal", "comanche", "cotton", "craig", "creek", "custer", "delaware",
      "dewey", "ellis", "garfield", "garvin", "grady", "grant", "greer",
      "harmon", "harper", "haskell", "hughes", "jackson", "jefferson", "johnston",
      "kay", "kingfisher", "kiowa", "latimer", "leflore", "lincoln", "logan",
      "love", "major", "marshall", "mayes", "mcclain", "mccurtain", "mcintosh",
      "murray", "muskogee", "noble", "nowata", "okfuskee", "oklahoma", "okmulgee",
      "osage", "ottawa", "pawnee", "payne", "pittsburg", "pontotoc", "pottawatomie",
      "pushmataha", "roger mills", "rogers", "seminole", "sequoyah", "stephens", "texas",
      "tillman", "tulsa", "wagoner", "washington", "washita", "woods", "woodward"
    )
  )

  # Test OSCN only
  expect_equal(
    ojo_list_counties(case = "lower", squish = FALSE, suffix = NULL, oscn_only = TRUE)$value,
    c(
      "adair", "canadian", "cleveland", "comanche",
      "ellis", "garfield", "logan", "oklahoma", "payne",
      "pushmataha", "roger mills", "rogers", "tulsa"
    )
  )

  # Test title case
  expect_equal(
    ojo_list_counties(case = "title", squish = FALSE, suffix = "COUNTY", oscn_only = TRUE)$value,
    c(
      "Adair County", "Canadian County", "Cleveland County", "Comanche County",
      "Ellis County", "Garfield County", "Logan County", "Oklahoma County", "Payne County",
      "Pushmataha County", "Roger Mills County", "Rogers County", "Tulsa County"
    )
  )

  # Test squish
  expect_equal(
    ojo_list_counties(case = "title", squish = TRUE, suffix = "county", oscn_only = TRUE)$value,
    c(
      "AdairCounty", "CanadianCounty", "ClevelandCounty", "ComancheCounty",
      "EllisCounty", "GarfieldCounty", "LoganCounty", "OklahomaCounty", "PayneCounty",
      "PushmatahaCounty", "RogerMillsCounty", "RogersCounty", "TulsaCounty"
    )
  )



})
