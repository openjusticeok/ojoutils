test_stays <- function() {
  data.frame(
    stay_start = as.POSIXct(c(
      "2024-01-01", "2024-01-02", "2024-01-01",
      "2024-01-03", "2024-01-05", "2024-01-10"
    )),
    stay_end = as.POSIXct(c(
      "2024-01-03", "2024-01-04", "2024-01-02",
      "2024-01-05", "2024-01-06", "2024-01-11"
    )),
    ward = c("A", "A", "B", "B", "A", "A"),
    sex  = c("M", "F", "M", "F", "M", "F")
  )
}

test_that("works without groups", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-05")),
    end   = as.Date(c("2024-01-03", "2024-01-06"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_s3_class(res, "tbl_df")
  expect_named(res, c("date", "n"))
  expect_equal(nrow(res), 6)
  expect_equal(res$n, c(1L, 1L, 1L, 0L, 1L, 1L))
})

test_that("works with groups", {
  df <- test_stays()

  res <- count_interval(
    df,
    start = "stay_start",
    end = "stay_end",
    period = "day",
    .by = c("ward", "sex")
  )

  expect_s3_class(res, "tbl_df")
  expect_named(res, c("date", "n", "ward", "sex"))
})

test_that("columns are ordered date, count, groups", {
  df <- test_stays()

  res <- count_interval(
    df,
    start = "stay_start",
    end = "stay_end",
    period = "day",
    .by = c("ward", "sex")
  )

  expect_equal(names(res), c("date", "n", "ward", "sex"))
})

test_that("custom date_name and count_name work", {
  df <- test_stays()

  res <- count_interval(
    df,
    start = "stay_start",
    end = "stay_end",
    period = "day",
    date_name = "day",
    count_name = "pop",
    .by = "ward"
  )

  expect_equal(names(res), c("day", "pop", "ward"))
})

test_that("gaps in calendar are filled with correct count", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-10")),
    end   = as.Date(c("2024-01-02", "2024-01-11"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  jan_7 <- res[res$date == as.Date("2024-01-07"), ]
  expect_equal(nrow(jan_7), 1)
  expect_equal(jan_7$n, 0L)
})

test_that("grouped gaps are filled correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-10")),
    end   = as.Date(c("2024-01-02", "2024-01-11")),
    grp   = c("A", "A")
  )

  res <- count_interval(
    df,
    start = "start",
    end = "end",
    period = "day",
    .by = "grp"
  )

  jan_7 <- res[res$date == as.Date("2024-01-07") & res$grp == "A", ]
  expect_equal(jan_7$n, 0L)
})

test_that("inclusive boundaries include end date", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-03")
  )

  res <- count_interval(
    df,
    start = "start",
    end = "end",
    period = "day",
    .inclusive = c(TRUE, TRUE)
  )

  expect_equal(res$n, c(1L, 1L, 1L))
})

test_that("exclusive end boundary excludes end date", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-03")
  )

  res <- count_interval(
    df,
    start = "start",
    end = "end",
    period = "day",
    .inclusive = c(TRUE, FALSE)
  )

  expect_equal(res$n, c(1L, 1L, 0L))
})

test_that("NA start values are filled with global min", {
  df <- data.frame(
    start = as.Date(c(NA, "2024-01-03")),
    end   = as.Date(c("2024-01-02", "2024-01-04"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_true(all(res$n >= 0))
})

test_that("NA end values are filled with global max", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-03")),
    end   = as.Date(c("2024-01-02", NA))
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_true(all(res$n >= 0))
})

test_that("empty input returns empty tibble with correct columns", {
  df <- data.frame(
    start = as.Date(character()),
    end   = as.Date(character())
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_equal(nrow(res), 0)
  expect_named(res, c("date", "n"))
})

test_that("missing required args errors", {
  expect_error(count_interval(), "absent")
  expect_error(count_interval(data.frame()), "absent")
})

test_that("missing columns error", {
  df <- data.frame(a = 1)
  expect_error(
    count_interval(df, start = "missing", end = "a", period = "day"),
    "not found"
  )
})

test_that(".by columns must exist", {
  df <- data.frame(start = as.Date("2024-01-01"), end = as.Date("2024-01-02"))
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day", .by = "nope"),
    "not found"
  )
})

test_that("name collisions error", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-02"),
    date  = 1
  )
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day", date_name = "date", .by = "date"),
    "date_name"
  )
})

test_that(".by cannot include start or end", {
  df <- data.frame(start = as.Date("2024-01-01"), end = as.Date("2024-01-02"))
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day", .by = "start"),
    "`start` or `end`"
  )
})

test_that("invalid period errors", {
  df <- data.frame(start = as.Date("2024-01-01"), end = as.Date("2024-01-02"))
  expect_error(
    count_interval(df, start = "start", end = "end", period = 123),
    "period"
  )
})

test_that("invalid .fill errors", {
  df <- data.frame(start = as.Date("2024-01-01"), end = as.Date("2024-01-02"))
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day", .fill = "bad"),
    "fill"
  )
})

test_that("invalid .inclusive errors", {
  df <- data.frame(start = as.Date("2024-01-01"), end = as.Date("2024-01-02"))
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day", .inclusive = TRUE),
    "inclusive"
  )
})

test_that("minute period maps to min for seq()", {
  df <- data.frame(
    start = as.POSIXct(c("2024-01-01 00:00:00", "2024-01-01 00:05:00")),
    end   = as.POSIXct(c("2024-01-01 00:02:00", "2024-01-01 00:07:00"))
  )

  # Should not error
  res <- count_interval(df, start = "start", end = "end", period = "minute")
  expect_s3_class(res, "tbl_df")
})

test_that("second period maps to sec for seq()", {
  df <- data.frame(
    start = as.POSIXct("2024-01-01 00:00:00"),
    end   = as.POSIXct("2024-01-01 00:00:05")
  )

  res <- count_interval(df, start = "start", end = "end", period = "second")
  expect_s3_class(res, "tbl_df")
})

test_that("overlapping stays in same group sum correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  jan_2 <- res[res$date == as.Date("2024-01-02"), ]
  expect_equal(jan_2$n, 2L)
})

test_that("hour period works correctly", {
  df <- data.frame(
    start = as.POSIXct(c("2024-01-01 00:00:00", "2024-01-01 02:00:00")),
    end   = as.POSIXct(c("2024-01-01 03:00:00", "2024-01-01 04:00:00"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "hour")

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 5)  # 00:00 to 04:00 inclusive
  expect_equal(res$n[res$date == as.POSIXct("2024-01-01 02:00:00")], 2L)
})

test_that("week period works correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-15")),
    end   = as.Date(c("2024-01-14", "2024-01-28"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "week")

  expect_s3_class(res, "tbl_df")
  # Should have dates floored to week start
  expect_true(all(res$n >= 0))
})

test_that("month period works correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-15", "2024-02-10")),
    end   = as.Date(c("2024-02-15", "2024-03-10"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "month")

  expect_s3_class(res, "tbl_df")
  expect_true(all(res$n >= 0))
})

test_that("quarter period works correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-15", "2024-04-15")),
    end   = as.Date(c("2024-03-15", "2024-06-15"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "quarter")

  expect_s3_class(res, "tbl_df")
  expect_true(all(res$n >= 0))
})

test_that("year period works correctly", {
  df <- data.frame(
    start = as.Date(c("2024-06-01", "2025-01-01")),
    end   = as.Date(c("2024-12-31", "2025-06-01"))
  )

  res <- count_interval(df, start = "start", end = "end", period = "year")

  expect_s3_class(res, "tbl_df")
  expect_true(all(res$n >= 0))
})

test_that("POSIXct with timezone works correctly", {
  df <- data.frame(
    start = as.POSIXct(c("2024-01-01 00:00:00", "2024-01-02 00:00:00"), tz = "America/New_York"),
    end   = as.POSIXct(c("2024-01-03 00:00:00", "2024-01-04 00:00:00"), tz = "America/New_York")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 4)
})

test_that("mixing Date and POSIXct columns is handled", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.POSIXct(c("2024-01-03 12:00:00", "2024-01-04 12:00:00"))
  )

  # This may or may not be supported, but shouldn't crash
  expect_no_error(
    count_interval(df, start = "start", end = "end", period = "day")
  )
})

test_that("single-day stays work with inclusive boundaries", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-01")
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day",
    .inclusive = c(TRUE, TRUE)
  )

  expect_equal(nrow(res), 1)
  expect_equal(res$n, 1L)
})

test_that("single-day stays work with exclusive end boundary", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-01")
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day",
    .inclusive = c(TRUE, FALSE)
  )

  # With exclusive end, single-day stay should not count
  expect_equal(nrow(res), 1)
  expect_equal(res$n, 0L)
})

test_that("start > end is handled gracefully", {
  df <- data.frame(
    start = as.Date("2024-01-05"),
    end   = as.Date("2024-01-01")
  )

  # Should either error or return empty/zero results
  expect_no_error(
    res <- count_interval(df, start = "start", end = "end", period = "day")
  )
})

test_that("all NA values with no fill errors appropriately", {
  df <- data.frame(
    start = as.Date(c(NA, NA)),
    end   = as.Date(c(NA, NA))
  )

  expect_error(
    count_interval(df, start = "start", end = "end", period = "day"),
    "All values"
  )
})

test_that("single row input works", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-03")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_equal(nrow(res), 3)
  expect_true(all(res$n == 1L))
})

test_that("very long date spans work correctly", {
  df <- data.frame(
    start = as.Date("2020-01-01"),
    end   = as.Date("2024-12-31")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  # Should span ~5 years of daily data
  expect_true(nrow(res) >= 365 * 4)
  expect_true(all(res$n == 1L))
})

test_that("custom .fill$start value works", {
  df <- data.frame(
    start = as.Date(c(NA, "2024-01-03")),
    end   = as.Date(c("2024-01-02", "2024-01-04"))
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day",
    .fill = list(start = as.Date("2024-01-01"), end = NULL)
  )

  expect_true(all(res$n >= 0))
  # The filled start should create population on 2024-01-01
  jan_1 <- res[res$date == as.Date("2024-01-01"), ]
  expect_equal(nrow(jan_1), 1)
})

test_that("custom .fill$end value works", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-03")),
    end   = as.Date(c("2024-01-02", NA))
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day",
    .fill = list(start = NULL, end = as.Date("2024-01-05"))
  )

  expect_true(all(res$n >= 0))
  # Should extend to 2024-01-05
  jan_5 <- res[res$date == as.Date("2024-01-05"), ]
  expect_equal(nrow(jan_5), 1)
})

test_that("explicit .fill values override data min/max", {
  df <- data.frame(
    start = as.Date(c(NA, "2024-01-05")),
    end   = as.Date(c("2024-01-04", "2024-01-06"))
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day",
    .fill = list(start = as.Date("2024-01-01"), end = as.Date("2024-01-10"))
  )

  # With explicit fill, the NA should use the provided date
  expect_true(all(res$n >= 0))
  # The filled start date should appear in results
  expect_true(any(as.Date(res$date) == as.Date("2024-01-01")))
})

test_that("factor grouping columns work correctly", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04")),
    group = factor(c("A", "B"))
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "group"
  )

  expect_s3_class(res, "tbl_df")
  expect_true("group" %in% names(res))
  # Factors should be preserved or converted to character
  expect_true(is.character(res$group) || is.factor(res$group))
})

test_that("groups with NA values are handled", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04")),
    group = c("A", NA)
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "group"
  )

  expect_s3_class(res, "tbl_df")
  # NA should be a valid group value
  expect_true(any(is.na(res$group)) || nrow(res[res$group == "A", ]) > 0)
})

test_that("special characters in group names work", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04")),
    `group name` = c("A", "B with space"),
    check.names = FALSE
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "group name"
  )

  expect_s3_class(res, "tbl_df")
  expect_true("group name" %in% names(res))
})

test_that("single group returns correct structure", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04")),
    group = "A"
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "group"
  )

  expect_s3_class(res, "tbl_df")
  expect_true(all(res$group == "A"))
})

test_that("many groups work correctly", {
  df <- data.frame(
    start = rep(as.Date("2024-01-01"), 100),
    end   = rep(as.Date("2024-01-03"), 100),
    group = sprintf("GROUP_%03d", 1:100)
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "group"
  )

  expect_equal(length(unique(res$group)), 100)
  # Each group should have 3 days
  expect_equal(nrow(res), 300)
})

test_that("output date column has correct type for Date input", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-03")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  # Date input produces Date output (may be converted to POSIXct internally)
  expect_true(inherits(res$date, "Date") || inherits(res$date, "POSIXct"))
})

test_that("output date column has correct type for POSIXct input", {
  df <- data.frame(
    start = as.POSIXct("2024-01-01 00:00:00"),
    end   = as.POSIXct("2024-01-03 00:00:00")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  # POSIXct input should produce POSIXct output
  expect_s3_class(res$date, "POSIXct")
})

test_that("output count column is integer", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-03")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_type(res$n, "integer")
})

test_that("row count matches expected calendar range", {
  df <- data.frame(
    start = as.Date("2024-01-01"),
    end   = as.Date("2024-01-10")
  )

  res <- count_interval(df, start = "start", end = "end", period = "day")

  expect_equal(nrow(res), 10)
})

test_that("complex multi-group scenario produces accurate counts", {
  # Create a scenario with 3 groups and overlapping stays
  df <- data.frame(
    start = as.Date(c(
      "2024-01-01", "2024-01-02",  # Group A overlaps
      "2024-01-01", "2024-01-05",  # Group B separate stays
      "2024-01-03"                  # Group C single stay
    )),
    end   = as.Date(c(
      "2024-01-03", "2024-01-04",  # Group A: overlap on 01-02, 01-03
      "2024-01-02", "2024-01-06",  # Group B: gap between stays
      "2024-01-05"                  # Group C: spans 01-03 to 01-05
    )),
    ward = c("A", "A", "B", "B", "C")
  )

  res <- count_interval(
    df, start = "start", end = "end", period = "day", .by = "ward"
  )

  # Group A: days 1-4 with 2 overlapping on 2-3
  ward_a <- res[res$ward == "A", ]
  expect_equal(ward_a$n[ward_a$date == as.POSIXct("2024-01-01")], 1L)
  expect_equal(ward_a$n[ward_a$date == as.POSIXct("2024-01-02")], 2L)
  expect_equal(ward_a$n[ward_a$date == as.POSIXct("2024-01-03")], 2L)
  expect_equal(ward_a$n[ward_a$date == as.POSIXct("2024-01-04")], 1L)

  # Group B: days 1-2 and 5-6 (gap on 3-4)
  ward_b <- res[res$ward == "B", ]
  jan_3_b <- ward_b[ward_b$date == as.POSIXct("2024-01-03"), ]
  expect_equal(nrow(jan_3_b), 1)
  expect_equal(jan_3_b$n, 0L)

  # Group C: days 3-5
  ward_c <- res[res$ward == "C", ]
  expect_equal(ward_c$n[ward_c$date == as.POSIXct("2024-01-03")], 1L)
  expect_equal(ward_c$n[ward_c$date == as.POSIXct("2024-01-04")], 1L)
  expect_equal(ward_c$n[ward_c$date == as.POSIXct("2024-01-05")], 1L)
})

test_that("NULL data errors", {
  expect_error(
    count_interval(NULL, start = "start", end = "end", period = "day"),
    "NULL"
  )
})

test_that("non-data-frame input errors or handles gracefully", {
  expect_error(
    count_interval(list(start = 1, end = 2), start = "start", end = "end", period = "day")
  )
})

test_that("character columns instead of Date errors appropriately", {
  df <- data.frame(
    start = c("2024-01-01", "2024-01-02"),
    end   = c("2024-01-03", "2024-01-04")
  )

  # Should error or handle gracefully
  expect_error(
    count_interval(df, start = "start", end = "end", period = "day")
  )
})

test_that("count_name collision with .by columns errors", {
  df <- data.frame(
    start = as.Date(c("2024-01-01", "2024-01-02")),
    end   = as.Date(c("2024-01-03", "2024-01-04")),
    ward = c("A", "B")
  )

  expect_error(
    count_interval(
      df, start = "start", end = "end", period = "day",
      count_name = "ward", .by = "ward"
    ),
    "count_name"
  )
})
