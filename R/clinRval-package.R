#' clinRval: Tools for Risk-Based Validation of R in Clinical Trials
#'
#' Provides functions and structured workflows to support risk-based validation
#' of R environments, packages, and analysis programs used in clinical trials.
#' Helps generate evidence suitable for regulatory submissions.
#'
#' @section Main functions:
#' - \code{\link{capture_environment}}: Record R version and packages
#' - \code{\link{verify_versions}}: Compare installed versions to an approved list
#' - \code{\link{read_renv_lock}}: Extract versions from an renv.lock file
#' - \code{\link{check_accuracy}}: Compare function output to expected value
#' - \code{\link{check_reproducibility}}: Confirm an expression is deterministic
#' - \code{\link{run_reference_tests}}: Built-in statistical accuracy checks
#' - \code{\link{tag_risk}}: Assign High/Medium/Low risk to packages
#' - \code{\link{run_clinical_tests}}: Clinical statistical reference tests
#' - \code{\link{log_validation}}: Append entries to a validation audit log
#' - \code{\link{export_results}}: Export validation results to CSV files
#'
#' @name clinRval
#' @keywords internal
"_PACKAGE"
