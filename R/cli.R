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
