#' @title Function to use the OJO quarto HTML template
#'
#' @description Wrapper for `quarto use template` command. Defaults to OJO html template.
#'
#' @param path The name of the directory where the template should be added. This should be a string representing an absolute path, or a path relative to the current working directory.
#' @param template The name of the Quarto template to use. This should be a string in the format "username/repository". Default is "openjusticeok/ojo-report-template".
#' @return This function does not return a value. If the user chooses not to proceed with the operation, the function exits silently.
#' @examples
#' \dontrun{
#' ojo_use_template(template = "openjusticeok/ojo-report-template", path = "my_directory")
#' }
ojo_use_template <- function(
    path,
    template = "openjusticeok/ojo-report-template"
) {
  command <- paste("quarto use template", template, "--no-prompt")

  full_dir <- dplyr::if_else(
    fs::is_absolute_path(path),
    path,
    fs::path_wd(path)
  )

  # Check if the directory exists
  if (!dir.exists(full_dir)) {
    # If not, ask if we should create it
    ans <- utils::menu(
      choices = c("Yes", "No"),
      title = paste0(
        "The path `",
        full_dir,
        "` does not exist.`",
        "`\nDo you want to create it?"
      )
    )
    # If they say no, just stop
    if (ans == 2) {
      return(invisible())
    }
    # Otherwise, go ahead
    fs::dir_create(full_dir)
  }

  # Check that the directory is empty
  if (!dir_empty(full_dir)) {
    cli::cli_abort(
      paste0(
        "Provided directory `", full_dir, "` is not empty!\n",
        "Please specify an empty directory (or enter the name of one to create) for the report to live in!"
      )
    )
  }

  # Confirm that directory is correct
  if (utils::menu(choices = c("Yes", "No"), title = paste0(
    "The template `",
    template,
    "` will be added to the directory `",
    full_dir,
    "`.\nDo you want to proceed?"
  )) == 2) {
    return(invisible())
  }

  # Run command
  withr::with_dir(new = full_dir, code = system(command))

  cli::cli_alert_success(paste0(
    "Template `", template, "` successfully added to directory `", full_dir, "`!"
  ))
}
