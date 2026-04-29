validate_project_name <- function(name) {
  stringr::str_detect(name, "^[a-z0-9]+(-[a-z0-9]+)*$")
}

#' @title Function to use the OKPolicy quarto website template
#' @description Wrapper for `quarto use template` command. Creates a new project directory
#'   and installs a Quarto template. The project name is derived from the last component
#'   of the path and must be in kebab-case format.
#' @param path Character. The path to the project directory. Can be absolute or relative
#'   to the current working directory. The last component of the path will be used as the
#'   project name and must be in kebab-case (lowercase letters, numbers, and hyphens only).
#' @param template Character. The type of project template to use. Must be one of:
#'   * `"website"` (default) - Multi-page website template
#'   * `"report"` - Single-page report template
#' @param .interactive Logical. Whether to prompt for user confirmation in interactive mode.
#'   Defaults to `rlang::is_interactive()`.
#'
#' @return Invisibly returns the result of the quarto command execution.
#'
#' @examples
#' \dontrun{
#' # Create a new website project (default)
#' ojo_use_template("my-new-website")
#'
#' # Create a report project
#' ojo_use_template("my-new-report", template = "report")
#'
#' # Create a project in a specific directory
#' ojo_use_template("~/Documents/Reports/my-new-website")
#'
#' # Create a project with interactive turned off
#' ojo_use_template("my-new-website", .interactive = FALSE)
#' }
#' @export
ojo_use_template <- function(
    path,
    template = c("website", "report"),
    .interactive = rlang::is_interactive()
) {
  # Validate template argument
  template <- rlang::arg_match(template)

  # Map friendly names to GitHub template specs
  template_spec <- switch(template,
    website = "openjusticeok/okpolicy-quarto-templates/okpolicy-website-template@mason-dev",
    report = "openjusticeok/okpolicy-quarto-templates/okpolicy-report-template@mason-dev"
  )

  # Path Resolution
  project_dir <- fs::path_abs(path)
  project_name <- fs::path_file(path)

  # Validate project name
  if (!validate_project_name(project_name)) {
    cli::cli_abort(c(
      "x" = "{.arg path} must end with a valid kebab-case project name.",
      "i" = "Allowed: lowercase letters, numbers, hyphens",
      "i" = "Examples: {.code my-project}, {.code report-2024}, {.code data-analysis}"
    ))
  }

  quarto_args <- c("use", "template", template_spec, "--no-prompt")

  # Find the executable
  quarto_bin <- quarto::quarto_path(normalize = TRUE)

  # Graceful fail if Quarto is not installed
  if (is.null(quarto_bin) || !nzchar(quarto_bin)) {
    cli::cli_abort("Quarto is not installed or could not be found.")
  }
  # Directory handling logic
  success <- FALSE
  
  if (!fs::dir_exists(project_dir)) {
    # Directory doesn't exist, create automatically
    cli::cli_alert_info("Creating directory {.path {project_dir}}...")
    fs::dir_create(project_dir)

    # Set up cleanup on failure
    on.exit(if (!success) try(fs::dir_delete(project_dir), silent = TRUE), add = TRUE)
  } else {
    # Directory exists, check if empty
    if (!dir_empty(project_dir)) {
      # Directory not empty, abort
      cli::cli_abort(c(
        "x" = "Directory {.path {project_dir}} exists and is not empty.",
        "i" = "Remove the directory first or choose a different path."
      ))
    }
    # Directory exists but empty, proceed without asking
  }

  # Confirm user wants to proceed (only for new directories in interactive mode)
  if (.interactive && !fs::dir_exists(project_dir)) {
    if (!cli_yeah("Install the template to {.path {project_dir}}?")) {
      cli::cli_alert_info("Aborted by user.")
      fs::dir_delete(project_dir)
      return(invisible())
    }
  }

  cli::cli_alert_info("Installing {.field {template}} template to {.path {project_dir}}...")

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
    "{.field {template}} template successfully added to directory {.path {project_dir}}!"
  )

  invisible(result)
}
