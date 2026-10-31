\name{resolve_dependencies}
\alias{resolve_dependencies}
\title{Resolve Package Dependencies}
\usage{
resolve_dependencies(packages, which = c("Depends", "Imports"), recursive = TRUE)
}
\arguments{
\item{packages}{Character vector of top-level package names.}

\item{which}{Character vector of dependency types to include.
Default is c("Depends", "Imports"). Use c("Depends", "Imports", "Suggests")
for a broader set.}

\item{recursive}{Logical; resolve dependencies of dependencies? Default TRUE.}
}
\value{
A data.frame with Package, Version, and Source (Direct or Dependency).
}
\description{
Identifies the full set of packages required by a given set of analysis
or reporting packages (Depends + Imports by default). Useful for documenting
the complete validated environment.
}
\examples{
resolve_dependencies(c("survival", "rmarkdown"))
}
