test_that("prepend_current_date works with different input formats", {
  # Test case for wrte_csv(parties, here(prepend_current_date("data/output/parties.csv")))
  expect_equal(
    prepend_current_date("data/output/parties.csv"),
    paste0("data/output/", format(Sys.Date(), "%Y_%m_%d"), "_parties.csv")
  )

  # Test case for write_csv(parties, prepend_current_date(here("data/output/parties.csv")))
  expect_equal(
    prepend_current_date(here::here("data/output/parties.csv")),
    here::here(paste0("data/output/", format(Sys.Date(), "%Y_%m_%d"), "_parties.csv"))
  )

  # Test case for write_csv(parties, here("data/output/", prepend_current_date(parties.csv)))
  expect_equal(
    prepend_current_date("parties.csv"),
    paste0(format(Sys.Date(), "%Y_%m_%d"), "_parties.csv")
  )
})

test_that("prepend_current_date works with append argument", {
  # Test case for appending the date
  expect_equal(
    prepend_current_date("data/output/parties.csv", append = TRUE),
    paste0("data/output/parties_", format(Sys.Date(), "%Y_%m_%d"), ".csv")
  )

  # Test case for appending the date with here package
  expect_equal(
    prepend_current_date(here::here("data/output/parties.csv"), append = TRUE),
    here::here(paste0("data/output/parties_", format(Sys.Date(), "%Y_%m_%d"), ".csv"))
  )
})
