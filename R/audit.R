#' Log a Validation Run
#'
#' Appends a timestamped entry to a simple validation audit log file.
#' Useful for documenting who ran validation activities and the outcome.
#'
#' @param action Character string describing the action (e.g., "Version verification").
#' @param status Character; typically "PASS" or "FAIL".
#' @param details Optional character string with extra information.
#' @param user Optional user name. Defaults to Sys.info()["user"].
#' @param logfile Path to the log file. Defaults to "validation_log.csv".
#' @return Invisible data.frame of the log entry that was written.
#' @export
#' @examples
#' # Write to a temporary file so the example is clean for R CMD check
#' tmp_log <- tempfile(fileext = ".csv")
#' log_validation("Environment capture", "PASS", "R 4.4.1 confirmed",
#'                logfile = tmp_log)
#' unlink(tmp_log)
log_validation <- function(action, status, details = "", user = NULL,
                           logfile = "validation_log.csv") {
  if (is.null(user)) {
    user <- Sys.info()[["user"]]
    if (is.null(user) || user == "") user <- "unknown"
  }

  entry <- data.frame(
    Timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    User = user,
    Action = action,
    Status = status,
    Details = details,
    stringsAsFactors = FALSE
  )

  if (file.exists(logfile)) {
    existing <- utils::read.csv(logfile, stringsAsFactors = FALSE)
    updated <- rbind(existing, entry)
  } else {
    updated <- entry
  }

  utils::write.csv(updated, logfile, row.names = FALSE)
  message("Validation log updated: ", logfile)
  invisible(entry)
}

#' Export Validation Results to CSV
#'
#' Writes one or more validation result objects to CSV files for archiving
#' in the Trial Master File or validation package.
#'
#' @param ... Named objects to export (data.frames or lists that can be coerced).
#' @param prefix Character prefix for output filenames. Default "validation_".
#' @param dir Directory to write files into. Default current directory.
#' @return Invisible character vector of file paths written.
#' @export
#' @examples
#' # Write to a temporary directory so the example is clean for R CMD check
#' env <- capture_environment(packages = "stats")
#' tmp_dir <- tempdir()
#' export_results(inventory = env$packages, prefix = "val_", dir = tmp_dir)
#' unlink(file.path(tmp_dir, "val_inventory.csv"))
export_results <- function(..., prefix = "validation_", dir = ".") {
  objects <- list(...)
  if (length(objects) == 0) {
    stop("No objects provided to export")
  }

  paths <- character(length(objects))
  names_obj <- names(objects)
  if (is.null(names_obj)) names_obj <- paste0("result", seq_along(objects))

  for (i in seq_along(objects)) {
    obj <- objects[[i]]
    filename <- file.path(dir, paste0(prefix, names_obj[i], ".csv"))

    if (is.data.frame(obj)) {
      utils::write.csv(obj, filename, row.names = FALSE)
    } else if (is.list(obj) && !is.null(obj$packages)) {
      utils::write.csv(obj$packages, filename, row.names = FALSE)
    } else {
      tryCatch({
        df <- as.data.frame(obj)
        utils::write.csv(df, filename, row.names = FALSE)
      }, error = function(e) {
        warning("Could not export object '", names_obj[i], "': ", e$message)
        filename <- NA
      })
    }
    paths[i] <- filename
  }

  message("Exported ", sum(!is.na(paths)), " file(s)")
  invisible(paths)
}
