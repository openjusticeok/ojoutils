#' @title Prepend Current Date
#'
#' @description Adds the current date to a file name.
#'
#' @param file_name A string representing the file name to which the date should be added.
#' @param append A logical value indicating whether to append the date instead of prepending it. Default is FALSE.
#'
#' @return A string with the current date added to the file name.
#'
#' @examples
#' prepend_current_date("data/output/parties.csv")
#' prepend_current_date("data/output/parties.csv", append = TRUE)
#'
#' @export
prepend_current_date <- function(file_name, append = FALSE) {
  # Get the current date in YYYY_MM_DD format
  current_date <- format(Sys.Date(), "%Y_%m_%d")
  
  # Extract the directory and file name
  dir <- dirname(file_name)
  base_name <- basename(file_name)
  
  # Add the current date to the file name
  if (append) {
    stamped_file_name <- file.path(dir, paste0(base_name, "_", current_date))
  } else {
    stamped_file_name <- file.path(dir, paste0(current_date, "_", base_name))
  }
  
  return(stamped_file_name)
}
