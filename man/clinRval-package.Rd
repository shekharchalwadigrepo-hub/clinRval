\name{clinRval-package}
\alias{clinRval}
\alias{clinRval-package}
\docType{package}
\title{Tools for Risk-Based Validation of R in Clinical Trials}
\description{
Provides functions and structured workflows to support risk-based validation
of R environments, packages, and analysis programs used in clinical trials.
Helps generate evidence suitable for regulatory submissions.
}
\details{
Main functions:
\itemize{
\item \code{\link{capture_environment}}: Record R version and packages
\item \code{\link{verify_versions}}: Compare installed versions to an approved list
\item \code{\link{read_renv_lock}}: Extract versions from an renv.lock file
\item \code{\link{check_accuracy}}: Compare function output to expected value
\item \code{\link{check_reproducibility}}: Confirm an expression is deterministic
\item \code{\link{run_reference_tests}}: Built-in statistical accuracy checks
\item \code{\link{tag_risk}}: Assign High/Medium/Low risk to packages
\item \code{\link{run_clinical_tests}}: Clinical statistical reference tests (SAS-style scenarios)
\item \code{\link{log_validation}}: Append entries to a validation audit log
\item \code{\link{export_results}}: Export validation results to CSV files
}
}
\author{
\strong{Maintainer}: Shekhar Chalwadi \email{skrchalwadicg@gmail.com}
}
\keyword{package}
