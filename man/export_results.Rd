\name{export_results}
\alias{export_results}
\title{Export Validation Results to CSV}
\usage{
export_results(..., prefix = "validation_", dir = ".")
}
\arguments{
\item{...}{Named objects to export (data.frames or lists that can be coerced).}

\item{prefix}{Character prefix for output filenames. Default "validation_".}

\item{dir}{Directory to write files into. Default current directory.}
}
\value{
Invisible character vector of file paths written.
}
\description{
Writes one or more validation result objects to CSV files for archiving
in the Trial Master File or validation package.
}
\examples{
env <- capture_environment(packages = "stats")
export_results(inventory = env$packages, prefix = "val_")
}
