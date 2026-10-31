\name{check_accuracy}
\alias{check_accuracy}
\title{Simple Accuracy Check for a Numeric Function}
\usage{
check_accuracy(fun, args, expected, tolerance = 1e-08)
}
\arguments{
\item{fun}{Function to test.}

\item{args}{List of arguments to pass to fun.}

\item{expected}{Expected numeric result.}

\item{tolerance}{Relative tolerance (default 1e-8).}
}
\value{
Logical indicating whether the result matches within tolerance,
plus the actual result as an attribute.
}
\description{
Compares the output of a function against a known reference value.
Useful for Operational Qualification (OQ) of statistical functions.
}
\examples{
check_accuracy(mean, list(c(1, 2, 3, 4)), expected = 2.5)
}
