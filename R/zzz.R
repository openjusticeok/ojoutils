#' @keywords internal
.onLoad <- function(libname, pkgname) {
  if (!arrow::arrow_with_gcs()) {
    cli::cli_warn(c(
      "Arrow was built without GCS support.",
      "i" = "GCS functions will not work properly.",
      "i" = "See {.url https://arrow.apache.org/docs/r/articles/install.html} for installation details."
    ))
  }
}
