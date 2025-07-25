test_that("stamp_date works with different input formats", {
  # Test case for write_csv(parties, here(stamp_date("data/output/parties.csv")))
  expect_equal(
    stamp_date("data/output/parties.csv"),
    paste0("data/output/", format(Sys.Date(), "%Y_%m_%d"), "_parties.csv")
  )

  # Test case for write_csv(parties, stamp_date(here("data/output/parties.csv")))
  expect_equal(
    stamp_date(here::here("data/output/parties.csv")),
    here::here(paste0("data/output/", format(Sys.Date(), "%Y_%m_%d"), "_parties.csv"))
  )

  # Test case for write_csv(parties, here("data/output/", stamp_date(parties.csv)))
  expect_equal(
    stamp_date("parties.csv"),
    paste0(format(Sys.Date(), "%Y_%m_%d"), "_parties.csv")
  )
})
