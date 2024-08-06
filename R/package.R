#' Create Package
#'
ojo_create_package <- function(
    name,
    description,
    dir = ".",
    private = TRUE,
    imports = NULL,
    depends = NULL,
    suggests = NULL,
    authors = NULL,
    rextendr = FALSE,
    rstudio = TRUE
) {
  # Get the initial working directory
  init_wd <- fs::path_wd()

  # TODO: Default to using OJO_PATH env var for project location

  # Get full path of project directory
  project_dir <- fs::path_abs(paste0(dir, "/", name))

  # Get package name
  package_name <- heck::to_lower_camel_case(name)

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

  # Create Github repo from package template
  gh_resp <- gh::gh(
      "POST /repos/openjusticeok/ojo-package-template/generate",
      owner = "openjusticeok",
      name = name,
      description = description,
      private = private
  )

  Sys.sleep(1)

  usethis::create_package(
    path = project_dir,
    rstudio = rstudio,
    roxygen = TRUE,
    check_name = FALSE,
    fields = list(
      Package = package_name,
      Description = description,
      Version = "0.0.0.9000"
    )
  )

  usethis::use_readme_rmd()
  usethis::use_gpl3_license()
  usethis::use_github_links(overwrite = TRUE)
  usethis::use_testthat(parallel = TRUE)
  usethis::use_pkgdown_github_pages()

  # Prefill readme with title line
  readr::write_lines(
    x = c(
      paste0("# {", package_name, "}"),
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
      "pak",
      "devtools",
      "usethis"
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
    message = "Scaffold package",
    repo = project_dir
  )

  # Push changes to Github
  gert::git_push(repo = project_dir)

  # Return the directory of the project invisibly
  invisible(project_dir)
}



#' @title Create Project
#' @description Creates a new R project with a standard directory structure
#'
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
