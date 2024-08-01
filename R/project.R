#' @title Create Project
#' @description Creates a new R project with a standard directory structure
#'
ojo_create_project <- function(name = NULL, dir = ".", private = TRUE) {
  # Get the initial working directory
  init_wd <- fs::path_wd()

  # TODO: Default to using OJO_PATH env var for project location

  # Get full path of project directory
  project_dir <- fs::path_abs(dir, name)

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

  # Init a project
  usethis::create_project(
    path = project_dir,
    rstudio = TRUE,
    open = FALSE
  )

  # Change working directory to new project
  setwd(project_dir)
  usethis::proj_set(project_dir)

  # Add a license
  usethis::use_gpl3_license()

  # Add a README
  usethis::use_readme_md(open = FALSE)

  # Prefill readme with title line
  readr::write_lines(
    x = paste0("# ", name),
    file = fs::path(project_dir, "README.md")
  )

  # TODO: Ask in cli if you want to edit the readme

  # Create a git repo
  gert::git_init(path = project_dir)

  fs::file_copy(
    path = system.file(
      "templates",
      "gitignore",
      package = "ojoutils",
      mustWork = TRUE
    ),
    new_path = fs::path(project_dir, ".gitignore"),
    overwrite = TRUE
  )

  # Create Github repo
  usethis::use_github(
    organisation = "openjusticeok",
    private = private,
    protocol = "ssh"
  )

  # Create default directory structure
  ## .gitkeep files make sure the empty R directory is pushed to git
  fs::file_create(project_dir, "R", ".gitkeep")

  fs::dir_create(project_dir, "data", "input")
  fs::dir_create(project_dir, "data", "ouput")
  fs::file_create(project_dir, "data", "input", ".gitkeep")
  fs::file_create(project_dir, "data", "output", ".gitkeep")

  fs::dir_create(project_dir, "inst", "figures")
  fs::file_create(project_dir, "inst", "figures", ".gitkeep")

  fs::dir_create(project_dir, "inst", "reports")
  fs::file_create(project_dir, "inst", "reports", ".gitkeep")

  # Stage all changed files
  gert::git_add(
    files = c("*", ".*"),
    repo = project_dir
  )

  # Commit changes
  gert::git_commit(
    message = "Scaffold file structure",
    repo = project_dir
  )

  # Push changes to Github
  gert::git_push(repo = project_dir)

  # Change working directory back
  setwd(init_wd)
  usethis::proj_set(init_wd)

  # Return the directory of the project invisibly
  invisible(project_dir)
}
