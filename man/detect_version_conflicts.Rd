\name{detect_version_conflicts}
\alias{detect_version_conflicts}
\title{Detect Package Version Conflicts}
\usage{
detect_version_conflicts(packages, which = c("Depends", "Imports"))
}
\arguments{
\item{packages}{Character vector of top-level package names to check.}

\item{which}{Dependency types to examine. Default c("Depends", "Imports").}
}
\value{
A data.frame of potential conflicts with columns:
Package, RequiredBy, Requirement, Installed, Conflict.
Empty data.frame if no conflicts found.
}
\description{
Identifies potential version conflicts by examining the dependency
requirements of a set of packages against currently installed versions.
Reports packages where installed version may not satisfy stated requirements.
}
\examples{
detect_version_conflicts(c("survival", "rmarkdown"))
}
