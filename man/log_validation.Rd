\name{log_validation}
\alias{log_validation}
\title{Log a Validation Run}
\usage{
log_validation(action, status, details = "", user = NULL,
               logfile = "validation_log.csv")
}
\arguments{
\item{action}{Character string describing the action (e.g., "Version verification").}

\item{status}{Character; typically "PASS" or "FAIL".}

\item{details}{Optional character string with extra information.}

\item{user}{Optional user name. Defaults to Sys.info()["user"].}

\item{logfile}{Path to the log file. Defaults to "validation_log.csv".}
}
\value{
Invisible data.frame of the log entry that was written.
}
\description{
Appends a timestamped entry to a simple validation audit log file.
Useful for documenting who ran validation activities and the outcome.
}
\examples{
log_validation("Environment capture", "PASS", "R 4.4.1 confirmed")
}
