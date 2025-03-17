#' @title Stamp Date
#'
#' @description Adds the current date to a file name.
#'
#' @param file_name A string representing the file name to which the date should be added.
#'
#' @return A string with the current date added to the file name.
#'
#' @examples
#' stamp_date("data/output/parties.csv")
#'
#' @export
stamp_date <- function(file_name) {
  # Get the current date in YYYY_MM_DD format
  current_date <- format(Sys.Date(), "%Y_%m_%d")
  
  # Extract the directory and file name
  dir <- dirname(file_name)
  base_name <- basename(file_name)
  
  # Add the current date to the file name
  stamped_file_name <- file.path(dir, paste0(current_date, "_", base_name))
  
  return(stamped_file_name)
}
