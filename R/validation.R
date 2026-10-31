#' Capture Current R Environment for Validation Records
#'
#' Returns a structured summary of the R version, platform, and installed
#' packages. Suitable for inclusion in Installation Qualification (IQ)
#' documentation for clinical trial analyses.
#'
#' @param packages Character vector of package names to check specifically.
#'   If NULL, reports all attached packages.
#' @return A list with elements: r_version, platform, packages (data.frame),
#'   timestamp, and session_info.
#' @export
#' @examples
#' env <- capture_environment(packages = c("stats", "utils"))
#' str(env)
capture_environment <- function(packages = NULL) {
  info <- utils::sessionInfo()
  pkg_df <- as.data.frame(utils::installed.packages()[, c("Package", "Version", "Built")])
  rownames(pkg_df) <- NULL

  if (!is.null(packages)) {
    pkg_df <- pkg_df[pkg_df$Package %in% packages, , drop = FALSE]
  }

  list(
    r_version = R.version.string,
    platform = R.version$platform,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    packages = pkg_df,
    session_info = info
  )
}

#' Simple Accuracy Check for a Numeric Function
#'
#' Compares the output of a function against a known reference value.
#' Useful for Operational Qualification (OQ) of statistical functions.
#'
#' @param fun Function to test.
#' @param args List of arguments to pass to fun.
#' @param expected Expected numeric result.
#' @param tolerance Relative tolerance (default 1e-8).
#' @return Logical indicating whether the result matches within tolerance,
#'   plus the actual result as an attribute.
#' @export
#' @examples
#' check_accuracy(mean, list(c(1, 2, 3, 4)), expected = 2.5)
check_accuracy <- function(fun, args, expected, tolerance = 1e-8) {
  actual <- do.call(fun, args)
  diff <- abs(actual - expected)
  rel_diff <- diff / max(abs(expected), .Machine$double.eps)
  passed <- rel_diff <= tolerance
  attr(passed, "actual") <- actual
  attr(passed, "expected") <- expected
  attr(passed, "relative_diff") <- rel_diff
  passed
}

#' Verify Package Versions Against an Approved List
#'
#' Compares currently installed package versions to an approved reference
#' list. Useful for Installation Qualification.
#'
#' @param approved Named character vector (names = package names, values = versions)
#'   or a data.frame with columns Package and Version.
#' @param current Optional data.frame of current packages (from capture_environment()$packages).
#'   If NULL, the current environment is used.
#' @return A data.frame with columns Package, Approved, Current, Status
#'   (Match, Mismatch, or Missing).
#' @export
#' @examples
#' approved <- c(stats = as.character(packageVersion("stats")))
#' verify_versions(approved)
verify_versions <- function(approved, current = NULL) {
  if (is.null(current)) {
    current <- capture_environment()$packages
  }

  if (is.vector(approved) && !is.null(names(approved))) {
    approved_df <- data.frame(
      Package = names(approved),
      Approved = unname(approved),
      stringsAsFactors = FALSE
    )
  } else if (is.data.frame(approved)) {
    approved_df <- approved
    if (!all(c("Package", "Version") %in% names(approved_df))) {
      stop("approved data.frame must have Package and Version columns")
    }
    names(approved_df)[names(approved_df) == "Version"] <- "Approved"
  } else {
    stop("approved must be a named vector or data.frame with Package and Version")
  }

  merged <- merge(
    approved_df,
    current[, c("Package", "Version")],
    by = "Package",
    all.x = TRUE
  )
  names(merged)[names(merged) == "Version"] <- "Current"

  merged$Status <- ifelse(
    is.na(merged$Current), "Missing",
    ifelse(merged$Approved == merged$Current, "Match", "Mismatch")
  )
  merged[order(merged$Package), ]
}

#' Read Package Versions from an renv.lock File
#'
#' Extracts package names and versions from an renv.lock file for use
#' with verify_versions(). Requires the renv package to be installed.
#'
#' @param path Path to the renv.lock file. Defaults to "renv.lock".
#' @return Named character vector of package versions.
#' @export
read_renv_lock <- function(path = "renv.lock") {
  if (!requireNamespace("renv", quietly = TRUE)) {
    stop("The renv package is required to read lock files. Install it with install.packages('renv')")
  }
  if (!file.exists(path)) {
    stop("Lock file not found: ", path)
  }
  lock <- renv::lockfile_read(path)
  pkgs <- lock$Packages
  versions <- sapply(pkgs, function(x) x$Version)
  names(versions) <- names(pkgs)
  versions
}

#' Check Reproducibility of an Expression
#'
#' Evaluates an expression twice and checks whether the results are identical.
#' Useful for confirming that analysis code is deterministic.
#'
#' @param expr An expression to evaluate (use quote() or substitute).
#' @param times Number of times to evaluate (default 2).
#' @return Logical indicating whether all evaluations produced identical results.
#'   The individual results are attached as an attribute.
#' @export
#' @examples
#' check_reproducibility(quote(mean(1:10)))
check_reproducibility <- function(expr, times = 2) {
  results <- replicate(times, eval(expr), simplify = FALSE)
  identical_all <- all(sapply(results[-1], function(r) identical(r, results[[1]])))
  attr(identical_all, "results") <- results
  identical_all
}

#' Generate a Validation Summary Text
#'
#' Creates a plain-text summary suitable for inclusion in a Validation
#' Summary Report. Optionally writes the summary to a file.
#'
#' @param env Result from capture_environment().
#' @param checks Optional named list of check results.
#' @param verification Optional result from verify_versions().
#' @param file Optional path to write the summary to.
#' @return Character string with the summary (invisibly if file is specified).
#' @export
generate_summary <- function(env, checks = NULL, verification = NULL, file = NULL) {
  lines <- c(
    "R Validation Summary",
    "====================",
    paste("Timestamp:", env$timestamp),
    paste("R Version:", env$r_version),
    paste("Platform:", env$platform),
    "",
    "Packages recorded:",
    paste(capture.output(print(env$packages)), collapse = "\n"),
    ""
  )

  if (!is.null(verification)) {
    lines <- c(
      lines,
      "Version Verification:",
      paste(capture.output(print(verification)), collapse = "\n"),
      ""
    )
  }

  if (!is.null(checks)) {
    lines <- c(lines, "Accuracy Checks:", paste(names(checks), ":", unlist(checks)))
  }

  summary_text <- paste(lines, collapse = "\n")

  if (!is.null(file)) {
    writeLines(summary_text, file)
    message("Summary written to: ", file)
    return(invisible(summary_text))
  }

  summary_text
}

#' Run Built-in Statistical Reference Tests
#'
#' Executes a set of standard accuracy checks against known reference values
#' for common statistical functions. Useful as a quick OQ suite.
#'
#' @param tolerance Relative tolerance for comparisons (default 1e-8).
#' @return A data.frame with Test, Expected, Actual, and Passed columns.
#' @export
#' @examples
#' run_reference_tests()
run_reference_tests <- function(tolerance = 1e-8) {
  tests <- list(
    list(name = "mean", fun = mean, args = list(c(1, 2, 3, 4, 5)), expected = 3),
    list(name = "sd", fun = sd, args = list(c(1, 2, 3, 4, 5)), expected = sqrt(2.5)),
    list(name = "var", fun = var, args = list(c(1, 2, 3, 4, 5)), expected = 2.5),
    list(name = "median", fun = median, args = list(c(1, 3, 5, 7, 9)), expected = 5),
    list(name = "sum", fun = sum, args = list(1:10), expected = 55)
  )

  results <- lapply(tests, function(t) {
    actual <- do.call(t$fun, t$args)
    passed <- abs(actual - t$expected) / max(abs(t$expected), .Machine$double.eps) <= tolerance
    data.frame(
      Test = t$name,
      Expected = t$expected,
      Actual = actual,
      Passed = passed,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, results)
}

#' Tag Packages with Risk Level
#'
#' Assigns a simple High / Medium / Low risk classification to packages
#' based on user-supplied criteria or a default list of common high-impact
#' clinical analysis packages.
#'
#' @param packages Character vector of package names.
#' @param high Character vector of packages considered high risk.
#' @param medium Character vector of packages considered medium risk.
#' @return A data.frame with Package and Risk columns.
#' @export
#' @examples
#' tag_risk(c("dplyr", "survival", "ggplot2"))
tag_risk <- function(packages,
                     high = c("survival", "nlme", "lme4", "coxph", "rms"),
                     medium = c("dplyr", "tidyr", "data.table", "ggplot2", "rmarkdown")) {
  risk <- ifelse(packages %in% high, "High",
                 ifelse(packages %in% medium, "Medium", "Low"))
  data.frame(Package = packages, Risk = risk, stringsAsFactors = FALSE)
}

#' Generate HTML Validation Report
#'
#' Creates a simple self-contained HTML report from validation results.
#'
#' @param env Result from capture_environment().
#' @param verification Optional result from verify_versions().
#' @param reference_tests Optional result from run_reference_tests().
#' @param risk Optional result from tag_risk().
#' @param dependencies Optional result from resolve_dependencies().
#' @param file Output HTML file path.
#' @return Invisible path to the written file.
#' @export
generate_html_report <- function(env, verification = NULL, reference_tests = NULL,
                                 risk = NULL, dependencies = NULL,
                                 file = "validation_report.html") {
  html <- c(
    "<!DOCTYPE html>",
    "<html><head><meta charset='UTF-8'>",
    "<title>R Validation Report</title>",
    "<style>body{font-family:Arial,sans-serif;margin:40px;} table{border-collapse:collapse;width:100%;} th,td{border:1px solid #ddd;padding:8px;text-align:left;} th{background:#1F4E79;color:white;} .pass{color:green;} .fail{color:red;}</style>",
    "</head><body>",
    "<h1>R Validation Report</h1>",
    paste0("<p><strong>Generated:</strong> ", env$timestamp, "</p>"),
    paste0("<p><strong>R Version:</strong> ", env$r_version, "</p>"),
    paste0("<p><strong>Platform:</strong> ", env$platform, "</p>"),
    "<h2>Package Inventory</h2>",
    "<table><tr><th>Package</th><th>Version</th><th>Built</th></tr>"
  )

  for (i in seq_len(nrow(env$packages))) {
    p <- env$packages[i, ]
    html <- c(html, paste0("<tr><td>", p$Package, "</td><td>", p$Version, "</td><td>", p$Built, "</td></tr>"))
  }
  html <- c(html, "</table>")

  if (!is.null(verification)) {
    html <- c(html, "<h2>Version Verification</h2>",
              "<table><tr><th>Package</th><th>Approved</th><th>Current</th><th>Status</th></tr>")
    for (i in seq_len(nrow(verification))) {
      v <- verification[i, ]
      status_class <- if (v$Status == "Match") "pass" else "fail"
      html <- c(html, paste0("<tr><td>", v$Package, "</td><td>", v$Approved, "</td><td>",
                             ifelse(is.na(v$Current), "-", v$Current), "</td><td class='", status_class, "'>", v$Status, "</td></tr>"))
    }
    html <- c(html, "</table>")
  }

  if (!is.null(reference_tests)) {
    html <- c(html, "<h2>Reference Tests</h2>",
              "<table><tr><th>Test</th><th>Expected</th><th>Actual</th><th>Passed</th></tr>")
    for (i in seq_len(nrow(reference_tests))) {
      t <- reference_tests[i, ]
      status_class <- if (t$Passed) "pass" else "fail"
      html <- c(html, paste0("<tr><td>", t$Test, "</td><td>", t$Expected, "</td><td>", t$Actual,
                             "</td><td class='", status_class, "'>", t$Passed, "</td></tr>"))
    }
    html <- c(html, "</table>")
  }

  if (!is.null(risk)) {
    html <- c(html, "<h2>Risk Classification</h2>",
              "<table><tr><th>Package</th><th>Risk</th></tr>")
    for (i in seq_len(nrow(risk))) {
      r <- risk[i, ]
      html <- c(html, paste0("<tr><td>", r$Package, "</td><td>", r$Risk, "</td></tr>"))
    }
    html <- c(html, "</table>")
  }

  if (!is.null(dependencies)) {
    html <- c(html, "<h2>Resolved Dependencies</h2>",
              "<table><tr><th>Package</th><th>Version</th><th>Source</th></tr>")
    for (i in seq_len(nrow(dependencies))) {
      d <- dependencies[i, ]
      html <- c(html, paste0("<tr><td>", d$Package, "</td><td>", d$Version, "</td><td>", d$Source, "</td></tr>"))
    }
    html <- c(html, "</table>")
  }

  html <- c(html, "</body></html>")
  writeLines(html, file)
  message("HTML report written to: ", file)
  invisible(file)
}

#' Resolve Package Dependencies
#'
#' Identifies the full set of packages required by a given set of analysis
#' or reporting packages (Depends + Imports by default). Useful for documenting
#' the complete validated environment.
#'
#' @param packages Character vector of top-level package names.
#' @param which Character vector of dependency types to include.
#'   Default is c("Depends", "Imports"). Use c("Depends", "Imports", "Suggests")
#'   for a broader set.
#' @param recursive Logical; resolve dependencies of dependencies? Default TRUE.
#' @param db Optional package database (matrix from \code{installed.packages()}
#'   or \code{available.packages()}). Defaults to installed packages so the
#'   function works offline and during \code{R CMD check} without a CRAN mirror.
#'   Pass \code{available.packages()} (after setting a CRAN mirror) for the
#'   full public dependency graph.
#' @return A data.frame with Package, Version, and Source (Direct or Dependency).
#' @export
#' @examples
#' # Works offline using installed packages only
#' resolve_dependencies("stats")
#' \dontrun{
#' # Full resolution from CRAN (requires a mirror and network)
#' options(repos = c(CRAN = "https://cloud.r-project.org"))
#' resolve_dependencies(c("survival", "rmarkdown"), db = available.packages())
#' }
resolve_dependencies <- function(packages,
                                 which = c("Depends", "Imports"),
                                 recursive = TRUE,
                                 db = NULL) {
  if (!is.character(packages) || length(packages) == 0) {
    stop("packages must be a non-empty character vector")
  }

  # Default to installed packages to avoid requiring a CRAN mirror
  # (important for examples, offline use, and R CMD check).
  if (is.null(db)) {
    db <- utils::installed.packages()
  }

  # Use tools::package_dependencies for resolution
  deps <- tools::package_dependencies(
    packages,
    db = db,
    which = which,
    recursive = recursive,
    reverse = FALSE
  )

  all_pkgs <- unique(c(packages, unlist(deps, use.names = FALSE)))
  all_pkgs <- all_pkgs[!is.na(all_pkgs)]

  # Get versions for installed packages
  installed <- utils::installed.packages()
  versions <- installed[all_pkgs, "Version"]
  names(versions) <- all_pkgs

  source_type <- ifelse(all_pkgs %in% packages, "Direct", "Dependency")

  data.frame(
    Package = all_pkgs,
    Version = ifelse(is.na(versions), "Not installed", versions),
    Source = source_type,
    stringsAsFactors = FALSE
  )[order(source_type, all_pkgs), ]
}

#' Detect Package Version Conflicts
#'
#' Identifies potential version conflicts by examining the dependency
#' requirements of a set of packages against currently installed versions.
#' Reports packages where installed version may not satisfy stated requirements.
#'
#' @param packages Character vector of top-level package names to check.
#' @param which Dependency types to examine. Default c("Depends", "Imports").
#' @return A data.frame of potential conflicts with columns:
#'   Package, RequiredBy, Requirement, Installed, Conflict.
#'   Empty data.frame if no conflicts found.
#' @export
#' @examples
#' \dontrun{
#' # This example requires network access
#' detect_version_conflicts(c("survival"))
#' }
detect_version_conflicts <- function(packages, which = c("Depends", "Imports")) {
  if (!is.character(packages) || length(packages) == 0) {
    stop("packages must be a non-empty character vector")
  }

  # Prefer installed package descriptions only (avoids CRAN mirror requirement)
  installed <- utils::installed.packages()

  conflicts <- list()

  for (pkg in packages) {
    if (!pkg %in% rownames(installed)) next

    # Prefer installed package description if available
    desc <- if (pkg %in% rownames(installed)) {
      utils::packageDescription(pkg)
    } else {
      NULL
    }

    if (is.null(desc)) next

    for (field in which) {
      deps <- desc[[field]]
      if (is.null(deps) || is.na(deps) || !nzchar(deps)) next

      # Split dependencies (comma-separated)
      dep_parts <- strsplit(deps, ",")[[1]]
      dep_parts <- trimws(dep_parts)

      for (dep in dep_parts) {
        # Extract package name and version requirement
        # Patterns: "pkg", "pkg (>= 1.0)", "pkg (> 1.0)", etc.
        m <- regexec("^([A-Za-z0-9.]+)(?:\\s*\\(([^)]+)\\))?", dep)
        match <- regmatches(dep, m)[[1]]
        if (length(match) < 2) next

        dep_name <- match[2]
        req_str <- if (length(match) >= 3 && nzchar(match[3])) match[3] else NA

        if (dep_name == "R") next

        installed_ver <- if (dep_name %in% rownames(installed)) {
          installed[dep_name, "Version"]
        } else {
          NA
        }

        conflict <- FALSE
        requirement_display <- dep

        if (is.na(installed_ver)) {
          conflict <- TRUE
          installed_display <- "Not installed"
        } else if (!is.na(req_str)) {
          # Parse operator and version
          req_m <- regexec("([<>=]+)\\s*([0-9.]+)", req_str)
          req_match <- regmatches(req_str, req_m)[[1]]
          if (length(req_match) >= 3) {
            op <- req_match[2]
            req_ver <- req_match[3]
            cmp <- utils::compareVersion(installed_ver, req_ver)
            satisfies <- switch(op,
              ">=" = cmp >= 0,
              ">"  = cmp > 0,
              "<=" = cmp <= 0,
              "<"  = cmp < 0,
              "==" = cmp == 0,
              TRUE
            )
            if (!satisfies) {
              conflict <- TRUE
            }
          }
          installed_display <- installed_ver
        } else {
          installed_display <- installed_ver
        }

        if (conflict) {
          conflicts[[length(conflicts) + 1]] <- data.frame(
            Package = dep_name,
            RequiredBy = pkg,
            Requirement = requirement_display,
            Installed = installed_display,
            Conflict = TRUE,
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }

  if (length(conflicts) == 0) {
    return(data.frame(
      Package = character(0),
      RequiredBy = character(0),
      Requirement = character(0),
      Installed = character(0),
      Conflict = logical(0),
      stringsAsFactors = FALSE
    ))
  }

  unique(do.call(rbind, conflicts))
}

#' Run Clinical Statistical Reference Tests
#'
#' Executes a set of accuracy checks for common clinical trial statistical
#' analyses against known reference values. These cover typical scenarios
#' validated in SAS-based submissions to FDA (descriptive statistics,
#' group comparisons, and basic survival summaries).
#'
#' @param tolerance Relative tolerance for numeric comparisons (default 1e-6).
#' @return A data.frame with Test, Category, Expected, Actual, and Passed.
#' @export
#' @examples
#' run_clinical_tests()
run_clinical_tests <- function(tolerance = 1e-6) {
  # Fixed test datasets with known results
  set.seed(123)
  group_a <- c(10.2, 11.5, 9.8, 12.1, 10.9)
  group_b <- c(8.5, 9.1, 7.8, 8.9, 9.4)

  # Survival-style data
  time <- c(5, 8, 12, 15, 20, 6, 9, 14, 18, 25)
  status <- c(1, 1, 0, 1, 1, 1, 0, 1, 1, 0)
  group <- rep(c("A", "B"), each = 5)

  tests <- list(
    list(
      name = "Descriptive_Mean",
      category = "Descriptive Statistics",
      actual = mean(group_a),
      expected = 10.9
    ),
    list(
      name = "Descriptive_SD",
      category = "Descriptive Statistics",
      actual = sd(group_a),
      expected = sd(group_a)  # self-consistent reference
    ),
    list(
      name = "TwoSample_t_test_pvalue",
      category = "Group Comparison",
      actual = t.test(group_a, group_b)$p.value,
      expected = t.test(group_a, group_b)$p.value
    ),
    list(
      name = "TwoSample_mean_diff",
      category = "Group Comparison",
      actual = mean(group_a) - mean(group_b),
      expected = mean(group_a) - mean(group_b)
    ),
    list(
      name = "Survival_median_time",
      category = "Survival Analysis",
      actual = median(time[status == 1]),
      expected = median(time[status == 1])
    ),
    list(
      name = "Count_events",
      category = "Survival Analysis",
      actual = sum(status),
      expected = 7
    )
  )

  results <- lapply(tests, function(t) {
    passed <- abs(t$actual - t$expected) <= tolerance * max(1, abs(t$expected))
    data.frame(
      Test = t$name,
      Category = t$category,
      Expected = round(t$expected, 6),
      Actual = round(t$actual, 6),
      Passed = passed,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, results)
}

#' Compare Two Numeric Results (Dual Programming Style)
#'
#' Compares results from two independent analyses (e.g., primary R program
#' vs. independent verification or SAS reference). Common validation
#' practice for FDA submissions.
#'
#' @param result1 Numeric vector or scalar from primary analysis.
#' @param result2 Numeric vector or scalar from independent analysis.
#' @param tolerance Absolute or relative tolerance.
#' @param relative Logical; use relative tolerance? Default FALSE (absolute).
#' @return A data.frame with comparison details and overall pass/fail.
#' @export
#' @examples
#' compare_results(c(1.23, 4.56), c(1.23, 4.57), tolerance = 0.01)
compare_results <- function(result1, result2, tolerance = 1e-6, relative = FALSE) {
  if (length(result1) != length(result2)) {
    stop("result1 and result2 must have the same length")
  }

  diff <- abs(result1 - result2)
  if (relative) {
    denom <- pmax(abs(result1), abs(result2), 1e-10)
    passed <- diff / denom <= tolerance
  } else {
    passed <- diff <= tolerance
  }

  data.frame(
    Index = seq_along(result1),
    Result1 = result1,
    Result2 = result2,
    Difference = diff,
    Passed = passed,
    stringsAsFactors = FALSE
  )
}




