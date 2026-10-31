test_that("capture_environment returns expected structure", {
  env <- capture_environment(packages = "stats")
  expect_true(is.list(env))
  expect_true("r_version" %in% names(env))
  # R.version.string is "R version ..." on release, "R Under development ..." on devel
  expect_true(is.character(env$r_version) && nzchar(env$r_version))
  expect_true(grepl("^R ", env$r_version))
  expect_s3_class(env$packages, "data.frame")
})

test_that("check_accuracy passes for correct mean", {
  result <- check_accuracy(mean, list(c(1, 2, 3)), expected = 2)
  expect_true(result)
})

test_that("check_accuracy fails for incorrect value", {
  result <- check_accuracy(mean, list(c(1, 2, 3)), expected = 99)
  expect_false(result)
})

test_that("verify_versions detects match", {
  approved <- c(stats = as.character(packageVersion("stats")))
  result <- verify_versions(approved)
  expect_equal(result$Status[1], "Match")
})

test_that("run_reference_tests returns results", {
  res <- run_reference_tests()
  expect_s3_class(res, "data.frame")
  expect_true(all(res$Passed))
})

test_that("run_clinical_tests returns results", {
  res <- run_clinical_tests()
  expect_s3_class(res, "data.frame")
  expect_true(all(res$Passed))
  expect_true("Descriptive Statistics" %in% res$Category)
})

test_that("log_validation creates log entry", {
  tmp <- tempfile(fileext = ".csv")
  entry <- log_validation("Test action", "PASS", logfile = tmp)
  expect_true(file.exists(tmp))
  expect_equal(entry$Status, "PASS")
  unlink(tmp)
})
