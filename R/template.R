#' @title Ask for Yes/No Confirmation
#'
#' @description Interactive yes/no confirmation with cli styling.
#'   Returns TRUE for yes, FALSE for no. Follows the pattern from cli issue #488.
#'
#' @param text The question text (supports cli styling)
#' @param yes Character vector of affirmative options (default: c("Yes", "yeah"))
#' @param no Character vector of negative options (default: c("No", "nope"))
#' @param n_yes Number of yes options to show (default: 1)
#' @param n_no Number of no options to show (default: 1)
#' @param shuffle Whether to shuffle the options (default: TRUE)
#' @param ... Additional arguments passed to cli::cli_alert()
#' @param .envir Environment for glue interpolation
#'
#' @return Logical TRUE for yes, FALSE for no
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' # Simple confirmation
#' if (cli_yeah("Delete all files?")) {
#'   # Proceed with deletion
#' }
#'
#' # Custom options
#' proceed <- cli_yeah(
#'   "Continue with migration?",
#'   yes = c("Yes, proceed", "Continue"),
#'   no = c("Cancel", "Stop")
#' )
#' }
cli_yeah <- function(
  text,
  yes = c("Yes", "yeah"),
  no = c("No", "nope"),
  n_yes = 1,
  n_no = 1,
  shuffle = TRUE,
  ...,
  .envir = parent.frame()
) {
  if (!rlang::is_interactive()) {
    cli::cli_abort(
      c(
        "User input required, but session is not interactive.",
        i = "Query: {text}"
      ),
      .envir = .envir
    )
  }

  n_yes <- min(n_yes, length(yes))
  n_no <- min(n_no, length(no))

  # Sample options
  qs <- c(sample(yes, n_yes), sample(no, n_no))

  if (shuffle) {
    qs <- sample(qs)
  }

  # Show the question
  cli::cli_alert(text, ..., .envir = .envir)

  # Present menu and get choice
  choice <- utils::menu(qs, title = "Choose an option:")

  # Return TRUE if yes option selected
  choice != 0L && qs[[choice]] %in% yes
}

#' @title Function to use the OKPolicy quarto website template
#' @description Wrapper for `quarto use template` command.
#' @param base_dir The base directory where the new project folder will be created. Will default to current dir in terminal.
#' @param project_name The name of the new project folder to create. This will create a sub-directory for the new project.
#' @param template The name of the Quarto template to use. Default is "openjusticeok/okpolicy-quarto-templates/okpolicy-website-template".
#' @param .interactive set if environment is interactive or not. Default is TRUE (terminal is interactive).
#'
#' @examples
#' \dontrun{
#' # Create a new project in the current directory
#' ojo_use_template(project_name = "my_new_project")
#'
#' # Create a project in a specific base directory
#' ojo_use_template(
#'   base_dir = "C:/Users/Documents/Reports",
#'   project_name = "my_new_project"
#' )
#' 
#' # Create a project in a specific base directory with interactive turned off
#' ojo_use_template(
#'   base_dir = "C:/Users/Documents/Reports",
#'   project_name = "my_new_project",
#'   .interactive = FALSE
#' )
#' 
#' # Can even specify another template
#' ojo_use_template(
#'   base_dir = "C:/Users/Documents/Reports",
#'   project_name = "my_new_project",
#'   template = "openjusticeok/okpolicy-quarto-templates/okpolicy-report-template",
#'   .interactive = FALSE
#' )
#' }
#' @export
ojo_use_template <- function(
    base_dir = ".",
    project_name,
    template = "openjusticeok/okpolicy-quarto-templates/okpolicy-website-template@mason-dev",
    .interactive = rlang::is_interactive()
) {
  quarto_args <- c("use", "template", template, "--no-prompt")

  # Path Resolution
  project_dir <- fs::path_abs(fs::path(base_dir, project_name))

  # Check if directory already exists
  #     if it exists installation will abort with error message posted to CLI
  if (fs::dir_exists(project_dir)) {
    cli::cli_abort(
      c(
        "x" = "Directory {.path {project_dir}} already exists!",
        "i" = "Please choose a different {.arg project_name} or remove the existing directory."
      )
    )
  }

  # Check if quarto is installed
  if (!requireNamespace("quarto", quietly = TRUE)) {
    cli::cli_abort("The {.pkg quarto} package is required to find the Quarto installation.")
  }

  # Find the executable
  quarto_bin <- quarto::quarto_path(normalize = TRUE)

  # Graceful fail if Quarto is not installed
  if (is.null(quarto_bin) || !nzchar(quarto_bin)) {
    cli::cli_abort("Quarto is not installed or could not be found.")
  }

  # Confirm user wants to proceed
  if (.interactive) {
    if (!cli_yeah("Create directory {.path {project_dir}} and install the template?")) {
      cli::cli_alert_info("Aborted by user.")
      return(invisible())
    }
  }

  # Create the target directory
  cli::cli_alert_info("Creating directory {.path {project_dir}}...")
  fs::dir_create(project_dir)
  success <- FALSE
  on.exit(if (!success) try(fs::dir_delete(project_dir), silent = TRUE), add = TRUE)

  cli::cli_alert_info("Running {.code quarto use template {template}}...")
  
  # Error/Status/StdErr/StdOut capturing
  result <- tryCatch(
    withr::with_dir(
      new = project_dir,
      code = {
        processx::run(
          command = quarto_bin,
          args = quarto_args,
          echo = .interactive,     # print the stdout of the command
          echo_cmd = .interactive, # print the command that will be run
          error_on_status = TRUE,  # if the command fails, throw an R error, which is then caught by the tryCatch block below
          spinner = .interactive   # show a spinner while the command is running
        )
      }
    ),
    # c() is concatenating the following CLI styling together for cli::abort message
    #   x = red 
    #   i = blue
    #   " " = invisible indent for clean continuation lines
    #   v = green
    #   ! = yellow warning
    system_command_status_error = function(error) {
      cli::cli_abort(
        c(
          "x" = "Quarto encountered an error. Template installation failed.", 
          # if quarto wrote a message to stderr write it to CLI, if not write "(no stderr)"
          " " = if (nzchar(error$stderr)) error$stderr else "(no stderr)", 
          "i" = "Exit status: {error$status}"
        ),
        parent = error
      )
    },
    # captures other errors that happen before or during quarto launch
    error = function(error) {
      cli::cli_abort(
        c(
          "!" = "Something went wrong while preparing the Quarto command.",
          "i" = conditionMessage(error)
        ),
        parent = error
      )
    }
  )

  success <- TRUE
  cli::cli_alert_success(
    "Template {.val {template}} successfully added to directory {.path {project_dir}}!"
  )

  invisible(result)
}
