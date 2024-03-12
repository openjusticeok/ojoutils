#' @title Oklahoma Counties
#'
#' @export ojo_counties
#'
ojo_counties <- c(
  "adair", "alfalfa", "atoka", "beaver", "beckham", "blaine", "bryan",
  "caddo", "canadian", "carter", "cherokee", "choctaw", "cimarron", "cleveland",
  "coal", "comanche", "cotton", "craig", "creek", "custer", "delaware",
  "dewey", "ellis", "garfield", "garvin", "grady", "grant", "greer",
  "harmon", "harper", "haskell", "hughes", "jackson", "jefferson", "johnston",
  "kay", "kingfisher", "kiowa", "latimer", "leflore", "lincoln", "logan",
  "love", "major", "marshall", "mayes", "mcclain", "mccurtain", "mcintosh",
  "murray", "muskogee", "noble", "nowata", "okfuskee", "oklahoma", "okmulgee",
  "osage", "ottawa", "pawnee", "payne", "pittsburg", "pontotoc", "pottawatomie",
  "pushmataha", "rogermills", "rogers", "seminole", "sequoyah", "stephens", "texas",
  "tillman", "tulsa", "wagoner", "washington", "washita", "woods", "woodward"
)

#' @title Parse Oklahoma Counties
#'
#' @importFrom stringr str_remove_all str_to_lower
#' @importFrom dplyr if_else
#'
#' @param county A string or character vector that represents an Oklahoma county
#' @param ... Placeholder for future arguments
#' @param case The case to format the county string to. One of "lower", "upper", or "title".
#' @param squish A boolean indicator of whether to remove whitespace
#' @param suffix Specification of a suffix to remove from each item in `county`. For example, " County, OK".
#' @param counties A vector of valid county names to match on.
#' @param .silent A currently unused argument.
#'
#' @export ojo_parse_county
#'
ojo_parse_county <- function(county, ..., case = "lower", squish = NULL, suffix = NULL, counties = ojo_counties, .silent = FALSE) {
  case <- rlang::arg_match0(
    arg = stringr::str_to_lower(case),
    values = c("lower", "upper", "title")
  )

  # Remove anything besides the oklahoma county name
  county <- stringr::str_remove_all(county, "(?i),|\\s|county") |>
    stringr::str_remove_all("\\P{L}") |>
    stringr::str_to_lower()

  county <- dplyr::if_else(
    county %in% counties,
    county,
    NA_character_
  )

  # Apply Casing
  county <- dplyr::case_when(
    case == "lower" ~ stringr::str_to_lower(county),
    case == "upper" ~ stringr::str_to_upper(county),
    case == "title" ~ stringr::str_to_title(county)
  )

  if (case == "title") {
    county <- dplyr::case_when(
      county == "Leflore" ~ "LeFlore",
      county == "Mcclain" ~ "McClain",
      county == "Mccurtain" ~ "McCurtain",
      county == "Rogermills" ~ "Roger Mills",
      TRUE ~ county
    )
  }

  if (isTRUE(squish)) {
    county <- stringr::str_remove_all(county, "\\s")
  }

  # Remember Le Flore and counties with spaces are formatted differently.
  # exceptions <- c("leflore", "mcclain", "mccurtain", "rogermills")

  return(county)
}
