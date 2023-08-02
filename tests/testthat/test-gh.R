test_that("existing repo is detected", {
  expect_true(
    gh_repo_exists("ojodb")
  )
})

test_that("non-existing repo is not detected", {
  repo <- stringi::stri_rand_strings(
    n = 1,
    length = 24,
    pattern = "[a-z0-9\\-]"
  )

  expect_false(
    gh_repo_exists(repo)
  )
})
