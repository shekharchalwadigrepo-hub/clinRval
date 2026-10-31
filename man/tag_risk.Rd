\name{tag_risk}
\alias{tag_risk}
\title{Tag Packages with Risk Level}
\usage{
tag_risk(packages, high = c("survival", "nlme", "lme4", "coxph", "rms"),
         medium = c("dplyr", "tidyr", "data.table", "ggplot2", "rmarkdown"))
}
\arguments{
\item{packages}{Character vector of package names.}

\item{high}{Character vector of packages considered high risk.}

\item{medium}{Character vector of packages considered medium risk.}
}
\value{
A data.frame with Package and Risk columns.
}
\description{
Assigns a simple High / Medium / Low risk classification to packages
based on user-supplied criteria or a default list of common high-impact
clinical analysis packages.
}
\examples{
tag_risk(c("dplyr", "survival", "ggplot2"))
}
