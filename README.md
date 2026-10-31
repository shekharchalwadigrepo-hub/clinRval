# clinRval

Tools for risk-based validation of R environments and code used in clinical trials.

**Author:** Shekhar Chalwadi  
**GitHub:** [shekharchalwadigrepo-hub/clinRval](https://github.com/shekharchalwadigrepo-hub/clinRval)  
**Email:** skrchalwadicg@gmail.com

## Installation

```r
# From GitHub (once pushed):
# remotes::install_github("shekharchalwadigrepo-hub/clinRval")

# Or from source:
# R CMD build clinRval
# R CMD INSTALL clinRval_0.1.1.tar.gz
```

## Quick Examples

### 1. Capture and verify your environment
```r
library(clinRval)

# Capture current R + selected packages
env <- capture_environment(packages = c("stats", "survival", "dplyr"))

# Check against approved versions
approved <- c(
  stats = as.character(packageVersion("stats")),
  survival = "3.5-7"
)
ver <- verify_versions(approved)
print(ver)
```

### 2. Check accuracy and reproducibility
```r
# Simple accuracy check
check_accuracy(mean, list(c(1, 2, 3, 4, 5)), expected = 3)

# Reproducibility check
check_reproducibility(quote(mean(1:10)))
```

### 3. Resolve dependencies and detect conflicts
```r
deps <- resolve_dependencies(c("survival", "rmarkdown"))
print(head(deps))

conflicts <- detect_version_conflicts(c("survival", "dplyr"))
if (nrow(conflicts) == 0) message("No conflicts found")
```

### 4. Run reference tests and generate reports
```r
# Built-in statistical reference tests
ref <- run_reference_tests()
print(ref)

# Text summary
summary_text <- generate_summary(env, verification = ver)
cat(summary_text)

# HTML report
generate_html_report(
  env = env,
  verification = ver,
  reference_tests = ref,
  file = "validation_report.html"
)
```

### 5. Audit log and CSV export
```r
# Log the validation activity
log_validation(
  action = "Full environment verification",
  status = "PASS",
  details = "All critical packages matched"
)

# Export results for the TMF
export_results(
  inventory = env$packages,
  verification = ver,
  reference_tests = ref,
  prefix = "study_validation_"
)
```

## Purpose

This package helps sponsors and CROs generate objective evidence that their R setup is suitable for producing outputs submitted to regulatory authorities (e.g., FDA). It does not replace a full Computer System Validation process but supplies practical helper functions and documentation templates.
