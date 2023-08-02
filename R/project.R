github_organization <- "openjusticeok"

ojo_project_types <- c("analysis")

#' @title Create a New Project
#'
#' @description |
#' Create a new project with the Open Justice Oklahoma directory structure.
#'
#' @param path The path to the new project
#' @param name The name of the new project
#' @param type The type of the new project
#' @param ... Placeholder for future arguments
#' @param rstudio Whether to open the project in RStudio after creation
#'
#' @return Invisibly returns the path to the new project
#'
#' @export
#'
ojo_create_project <- function(path = ".", name = NULL, type = "analysis", ..., rstudio = TRUE) {

  path <- fs::path(path)

  # Check the path
  path_exists <- fs::dir_exists(path)

  if (!path_exists) {
    fs::dir_create(path)
  }

  # Check the naming convention
  if (is.null(name)) {
    name <- fs::path_dir(path)
  }

  name_valid <- stringr::str_detect(name, "^[a-z0-9\\-]+$")

  if (!name_valid) {
    rlang::abort("Project name must be lowercase and contain only letters, numbers, and hyphens.")
  }

  # Check if the project already exists on GitHub
  repo_exists <- gh_repo_exists(name)

  if (repo_exists) {
    rlang::abort("Project already exists on GitHub.")
  }

  # Create the project
  usethis::create_project(path = path, rstudio = rstudio, open = FALSE)

  # Add the default gitignore
  temp_gitignore <- system.file("templates", "gitignore", package = "ojoutils")

  if (!fs::file_exists(temp_gitignore)) {
    rlang::abort("Could not find default gitignore template.")
  }

  fs::file_copy(path, temp_gitignore, overwrite = TRUE)

  # Add the default README
  temp_readme <- system.file("templates", "README.md", package = "ojoutils")

  if (!fs::file_exists(temp_readme)) {
    rlang::abort("Could not find default README template.")
  }

  fs::file_copy(path, temp_readme, overwrite = TRUE)

  # Add the default LICENSE
  temp_license <- system.file("templates", "LICENSE", package = "ojoutils")

  if (!fs::file_exists(temp_license)) {
    rlang::abort("Could not find default LICENSE template.")
  }

  fs::file_copy(path, temp_license, overwrite = TRUE)

  # Add the default directory structure
  fs::dir_create(fs::path(path, "data"))
  fs::dir_create(fs::path(path, "data-raw"))
  fs::dir_create(fs::path(path, "docs"))
  fs::dir_create(fs::path(path, "outputs"))
  fs::dir_create(fs::path(path, "reports"))

  # Git commit everything
  gert::git_commit_all(
    message = "Initial commit",
    repo = path
  )

  # Git push everything

  # Switch to the new branch

  # Push the new branch to remote

  # Open the project in RStudio

}
