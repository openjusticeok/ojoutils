ojo_publish <- function(path, ..., draft = TRUE, public = FALSE, platform = "google") {
  publish_to_google(path = path, bucket = "publishr", public = public)
}

publish_to_google <- function(path, bucket, public) {
  if (!fs::file_exists(path)) {
    cli::cli_abort("`{path}` doesn't exist")
  }

  file_type <- dplyr::case_when(
    fs::is_file(path) ~ "file",
    fs::is_dir(path) ~ "dir",
    TRUE ~ NA_character_
  )

  if (is.na(file_type)) {
    cli::cli_abort("`{path}` is not recognized as a valid file or directory")
  }

  file_name <- fs::path_file(path)
  dir_name <- file_name |>
    fs::path_ext_remove()

  if (gcs_dir_exists(dir_name)) {
    cli::cli_abort("A Google Cloud Storage folder with the name `{dir_name}` already exists in bucket `{bucket}`")
  }

  if (file_type == "file") {
    res <- googleCloudStorageR::gcs_upload(
      path,
      bucket = bucket,
      name = stringr::str_glue("{dir_name}/{file_name}")
    )
  } else if (file_type == "dir") {
    cli::cli_abort("Not implemented") # TODO: Handle bulk upload of a directory
  }

  res_url <- googleCloudStorageR::gcs_download_url(
    object_name = res$name,
    bucket = res$bucket,
    public = public # TODO: Replace with signed_url?
  )

  cli::cli_alert_success("{.url {res_url}}")

  invisible(res)
}

gcs_object_exists <- function(object, bucket = "publishr") {
  x <- googleCloudStorageR::gcs_list_objects(bucket = bucket) |>
    dplyr::mutate(
      name = stringr::str_remove(name, "/$") # Remove trailing slash from object names
    )

  object %in% x$name
}

gcs_dir_exists <- function(object, bucket = "publishr") {
  x <- googleCloudStorageR::gcs_list_objects(bucket = bucket) |>
    dplyr::filter(stringr::str_detect(name, "/$")) |> # Only keep directories
    dplyr::mutate(
      name = stringr::str_remove(name, "/$") # Remove trailing slash from object names
    )

  object %in% x$name
}
