gh_repo_exists <- function(repo, owner = github_organization) {
  res <- tryCatch(
    gh::gh("/repos/{owner}/{repo}", owner = owner, repo = repo),
    error = function(e) { return(e) }
  )

  if (inherits(res, "error")) {
    if (res$message == "GitHub API error (404):  Not Found") {
      return(FALSE)
    } else {
      rlang::abort(res$message)
    }
  }

  if (inherits(res, "gh_response")) {
    return(TRUE)
  }

  rlang::abort("Unknown error occurred.")
}
