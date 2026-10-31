# clinRval

Tools for risk-based validation of R environments and code used in clinical trials.

## Installation

```r
# Once on CRAN:
install.packages("clinRval")

# Or from source:
# R CMD build clinRval
# R CMD INSTALL clinRval_0.2.0.tar.gz
```

## Quick Start

```r
library(clinRval)

# Capture environment for IQ records
env <- capture_environment(packages = c("dplyr", "survival"))

# Verify against approved versions
approved <- c(dplyr = "1.1.4", survival = "3.5-7")
ver <- verify_versions(approved)

# Accuracy check for OQ
check_accuracy(mean, list(c(1, 2, 3, 4, 5)), expected = 3)

# Reproducibility check
check_reproducibility(quote(mean(rnorm(100))))

# Generate summary text (optionally write to file)
summary <- generate_summary(env, verification = ver)
cat(summary)
```

## Purpose

This package helps sponsors and CROs generate objective evidence that their R setup is suitable for producing outputs submitted to regulatory authorities (e.g., FDA). It does not replace a full Computer System Validation process but supplies practical helper functions and documentation templates.

**Author:** Shekhar Chalwadi  
**GitHub:** [shekharchalwadigrepo-hub/clinRval](https://github.com/shekharchalwadigrepo-hub/clinRval)  
**Email:** skrchalwadicg@gmail.com
