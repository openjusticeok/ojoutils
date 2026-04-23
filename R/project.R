#' @title Create Project
#' @description Creates a new R project with a standard directory structure
#'
#' @section Getting Started:
#' To learn more about creating projects, see the vignette:
#' \code{vignette("project-creation", package = "ojotools")}
#'
#' @param name Character string. Name of the project/repo. If `NULL`, will attempt
#'   interactive prompt.
#' @param description Character string. Description of the project for GitHub.
#' @param dir Character string. Directory where project should be created.
#'   Defaults to current working directory.
#' @param private Logical. Whether the GitHub repository should be private.
#'   Defaults to `TRUE`.
#' @param packages Character vector. Additional packages to install in the
#'   project's renv environment. Currently not implemented.
#'
#' @return Invisible path to the created project directory.
#' @export
#'
#' @examples
#' \dontrun{
#' ojo_create_project("my-analysis", "Analysis of court data")
#' }
#'
#' @importFrom fs path_wd path_abs
#' @importFrom rlang is_interactive abort
#' @importFrom gh gh
#' @importFrom usethis create_from_github
#' @importFrom glue glue
#' @importFrom readr write_lines
#' @importFrom renv init install
#' @importFrom gert git_add git_commit git_push
ojo_create_project <- function(name = NULL, description = NULL, dir = ".", private = TRUE, packages = NULL) {
  # Get the initial working directory
  init_wd <- fs::path_wd()

  # TODO: Default to using OJO_PATH env var for project location

  # Get full path of project directory
  project_dir <- fs::path_abs(paste0(dir, "/", name))

  # If name is NULL, first try to use interactive CLI, otherwise fail
  if (is.null(name)) {
    if (rlang::is_interactive()) {
      # TODO: Get variable interactively
    } else {
      rlang::abort("No project name provided, and no support for interactive definition available in this environment.")
    }
  }

  # TODO: Check name matches conventions and isn't taken
  # TODO: If interactive, offer to change

  # TODO: Check description format
  # TODO: If description NULL offer to create

  # TODO: Wrap API call and issue custom error message
  # Create Github repo from project template
  gh_resp <- gh::gh(
    "POST /repos/openjusticeok/ojo-project-template/generate",
    owner = "openjusticeok",
    name = name,
    description = description,
    private = private
  )

  # Have to give github the time to transfer the repo
  # TODO: Base this on an API call?
  Sys.sleep(1)

  usethis::create_from_github(
    repo_spec = glue::glue("git@github.com:openjusticeok/{name}.git"),
    destdir = dir,
    fork = FALSE,
    rstudio = TRUE,
    open = FALSE,
    protocol = "ssh"
  )

  # Prefill readme with title line
  readr::write_lines(
    x = c(
      paste0("# ", name),
      description
    ),
    sep = "\n\n",
    file = fs::path(project_dir, "README.md"),
    append = FALSE
  )

  # TODO: Ask in cli if you want to edit the readme further

  # Init renv
  renv::init(
    project = project_dir,
    bare = TRUE,
    load = FALSE,
    restart = FALSE
  )

  # Add pak
  renv::install(
    packages = c(
      "pak"
    ),
    prompt = FALSE,
    lock = TRUE,
    project = project_dir
  )

  # Stage all changed files
  gert::git_add(
    files = c("*", ".*"),
    repo = project_dir
  )

  # Commit changes
  gert::git_commit(
    message = "Scaffold project",
    repo = project_dir
  )

  # Push changes to Github
  gert::git_push(repo = project_dir)

  # Return the directory of the project invisibly
  invisible(project_dir)
}
