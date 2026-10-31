# Complete clinRval example workflow
# Run this script to see a typical validation session

library(clinRval)

message("=== 1. Capture Environment ===")
env <- capture_environment(packages = c("stats", "utils"))
print(env$r_version)
print(head(env$packages))

message("\n=== 2. Version Verification ===")
approved <- c(stats = as.character(packageVersion("stats")))
ver <- verify_versions(approved)
print(ver)

message("\n=== 3. Accuracy & Reproducibility ===")
print(check_accuracy(mean, list(1:5), expected = 3))
print(check_reproducibility(quote(sd(1:10))))

message("\n=== 4. Reference Tests ===")
ref <- run_reference_tests()
print(ref)

message("\n=== 5. Risk Tagging ===")
risk <- tag_risk(c("survival", "dplyr", "stats"))
print(risk)

message("\n=== 6. Generate Summary ===")
summary_text <- generate_summary(env, verification = ver)
cat(summary_text)

message("\n=== 7. Log & Export ===")
log_validation("Example workflow", "PASS", "Completed successfully")
export_results(
  inventory = env$packages,
  verification = ver,
  reference = ref,
  prefix = "example_"
)

message("\n=== Done. Check example_*.csv and validation_log.csv ===")
