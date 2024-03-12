#' Function to use the OJO quarto HTML template
#'
#' Wrapper for `quarto use template` command. Defaults to OJO html template.
#'
#' @param template The name of the Quarto template to use. This should be a string in the format "username/repository". Default is "openjusticeok/ojo-report-template".
#' @param directory The name of the directory where the template should be added. This should be a string representing a path relative to the current working directory.
#' @return This function does not return a value. If the user chooses not to proceed with the operation, the function exits silently.
#' @examples
#' \dontrun{
#' ojo_use_template(template = "openjusticeok/ojo-report-template", directory = "my_directory")
#' }
ojo_use_template <- function(template = "openjusticeok/ojo-report-template",
                             directory) {
  command <- paste("quarto use template", template, "--no-prompt")

  full_dir <- paste0(getwd(), "/", directory)

  # Check that the directory is empty
  if (length(dir(directory)) > 0) {
    cli::cli_abort(
      paste0(
        "Provided directory `", full_dir, "` is not empty!\n",
        "Please specify an empty directory (or enter the name of one to create) for the report to live in!"
      )
    )
  }

  # Confirm that directory is correct
  if (menu(choices = c("Yes", "No"), title = paste0("The template `",
                                                    template,
                                                    "` will be added to the directory `",
                                                    full_dir,
                                                    "`.\nDo you want to proceed?")) == 2) {
    return(invisible())
  }

  # Create directory if it doesn't exist
  if (!dir.exists(directory)) {
    cli::cli_alert_info(paste0(
      "directory `", full_dir, "` does not exist. Creating now...")
    )
    dir.create(directory)
  }

  # Run command
  withr::with_dir(new = directory, code = system(command))

  cli::cli_alert_success(paste0(
    "Template `", template, "` successfully added to directory `", full_dir, "`!"
  ))

}
