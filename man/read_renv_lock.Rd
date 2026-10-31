\name{read_renv_lock}
\alias{read_renv_lock}
\title{Read Package Versions from an renv.lock File}
\usage{
read_renv_lock(path = "renv.lock")
}
\arguments{
\item{path}{Path to the renv.lock file. Defaults to "renv.lock".}
}
\value{
Named character vector of package versions.
}
\description{
Extracts package names and versions from an renv.lock file for use
with verify_versions(). Requires the renv package to be installed.
}
