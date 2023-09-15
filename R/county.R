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

#' @title Oklahoma OSCN reporting counties
#'
#' @export ojo_oscn_counties
#'
ojo_oscn_counties <- c(
  "adair", "canadian", "cleveland", "comanche",
  "ellis", "garfield", "logan", "oklahoma", "payne",
  "pushmataha", "rogermills", "rogers", "tulsa"
)

#' @title Parse Oklahoma Counties
#'
#' @importFrom stringr str_remove_all str_to_lower
#' @importFrom dplyr if_else
#'
#' @export ojo_parse_county
#'
ojo_parse_county <- function(county, ..., case = "lower", squish = FALSE, suffix = NULL,
                             counties = ojo_counties, .silent = FALSE) {

  # Check case arg
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
    # Adjusting for unusual district names
    tolower(county) == "rogermills" & case == "lower" ~ "roger mills",
    tolower(county) == "rogermills" & case == "title" ~ "Roger Mills",
    tolower(county) == "rogermills" & case == "upper" ~ "ROGER MILLS",
    tolower(county) == "leflore" & case == "title" ~ "LeFlore",
    tolower(county) == "mcclain" & case == "title" ~ "McClain",
    tolower(county) == "mccurtain" & case == "title" ~ "McCurtain",
    # Normal behavior
    case == "lower" ~ stringr::str_to_lower(county),
    case == "upper" ~ stringr::str_to_upper(county),
    case == "title" ~ stringr::str_to_title(county),
  )

  # Add suffix if requested
  if (!is.null(suffix)) {
    # Change case...
    suffix <- dplyr::case_when(
      case == "lower" ~ stringr::str_to_lower(suffix),
      case == "upper" ~ stringr::str_to_upper(suffix),
      case == "title" ~ stringr::str_to_title(suffix),
    )
    # ...then add
    county <- stringr::str_c(county, suffix, sep = " ")
  }

  # Remove all spaces if requested
  if (isTRUE(squish)) {
    county <- stringr::str_remove_all(county, "\\s")
  }

  # Handle exceptional cases
  if (case == "title" & isTRUE(squish)) {
    county <- dplyr::case_when(
      tolower(county) == "leflore" ~ "LeFlore",
      tolower(county) == "mcclain" ~ "McClain",
      tolower(county) == "mccurtain" ~ "McCurtain",
      tolower(county) == "rogermills" ~ "RogerMills",
      TRUE ~ county
    )
  } else if (case == "title" & isFALSE(squish)) {
    county <- dplyr::case_when(
      tolower(county) == "leflore" ~ "LeFlore",
      tolower(county) == "mcclain" ~ "McClain",
      tolower(county) == "mccurtain" ~ "McCurtain",
      tolower(county) == "rogermills" ~ "Roger Mills",
      TRUE ~ county
    )
  }

  # Remember Le Flore and counties with spaces are formatted differently.
  # exceptions <- c("leflore", "mcclain", "mccurtain", "rogermills")

  return(county)
}

#' @title List Oklahoma Counties
#'
#' @export ojo_list_counties
#'
ojo_list_counties <- function(case = "lower", squish = FALSE, suffix = NULL,
                              oscn_only = FALSE){

  # Clean the list of counties using ojo_parse_counties() and then return
  county <- ojo_counties |>
    dplyr::as_tibble() |>
    dplyr::mutate(
      value = ojoutils::ojo_parse_county(county = value,
                                         case = case,
                                         squish = squish,
                                         suffix = suffix,
                                         .silent = TRUE)
    )

  # Only return OSCN counties?
  if (oscn_only) {
    county <- county |>
      dplyr::filter(
        ojo_parse_county(value, case = "lower", squish = TRUE) %in% ojo_oscn_counties
      )
  }

  return(county)

}
