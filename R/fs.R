#' @title Directory Empty?
#'
#' @description Takes a path and determines whether it is empty.
#'
#' @param path A relative or absolute path to the directory to test.
#'
#' @returns `TRUE` if the directory is empty, otherwise `FALSE`.
#' If the directory doesn't exist, or the string supplied to `path` isn't
#' recognized as a valid path, then the function returns an error.
#'
dir_empty <- function(path) {
  if (!fs::dir_exists(path) | !fs::is_dir(path)) {
    rlang::abort("The path doesn't exist or isn't really a path")
  }

  num_files <- length(fs::dir_ls(path = path))

  if (num_files > 0) {
    return(FALSE)
  }

  return(TRUE)
}
