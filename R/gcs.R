#' Authenticate with Google Cloud Storage
#'
#' @description
#' Authenticates with Google Cloud Storage (GCS) using the gargle package for
#' OAuth2 token fetching, then sets the specified bucket as the global bucket
#' for subsequent GCS operations.
#'
#' @details
#' This function uses `gargle::token_fetch()` to obtain an OAuth2 token with
#' cloud-platform scope, then authenticates with `googleCloudStorageR`. It sets
#' the global bucket so that subsequent GCS operations don't need to specify
#' the bucket parameter repeatedly.
#'
#' The function returns the bucket name invisibly, making it suitable for use
#' in pipelines where you want to authenticate and continue processing.
#'
#' @param bucket Character string. The name of the GCS bucket to set as the
#'   global bucket for subsequent operations.
#'
#' @return The bucket name (invisibly).
#'
#' @examples
#' \dontrun{
#' # Authenticate and set a specific bucket as global
#' gcs_auth_bucket("my-project-data")
#'
#' # Can be used in a pipeline
#' "my-project-data" |> gcs_auth_bucket()
#' }
#'
#' @seealso [googleCloudStorageR::gcs_auth()] for more authentication options
#'
#' @importFrom gargle token_fetch
#' @importFrom googleCloudStorageR gcs_auth gcs_global_bucket
#' @export
gcs_auth_bucket <- function(bucket) {
  scope <- "https://www.googleapis.com/auth/cloud-platform"
  token <- gargle::token_fetch(scopes = scope)
  googleCloudStorageR::gcs_auth(token = token)
  googleCloudStorageR::gcs_global_bucket(bucket = bucket)
  invisible(bucket)
}

#' Read a CSV file from Google Cloud Storage
#'
#' @description
#' Reads a CSV file from Google Cloud Storage into a data frame using the
#' arrow package for efficient reading. Optionally cleans column names using
#' janitor::clean_names().
#'
#' @details
#' This function uses arrow's CSV reader which is optimized for performance
#' and can handle large files efficiently. The GCS path is constructed using
#' glue for safe string interpolation.
#'
#' By default, column names are cleaned using janitor::clean_names() to convert
#' them to snake_case and remove special characters. Set `clean_names = FALSE`
#' to preserve original column names.
#'
#' @param bucket Character string. The name of the GCS bucket containing the file.
#' @param object Character string. The path to the CSV file within the bucket.
#' @param clean_names Logical. If `TRUE` (default), column names are cleaned
#'   using [janitor::clean_names()]. If `FALSE`, original column names are preserved.
#'
#' @return A data frame (tibble) containing the CSV data.
#'
#' @examples
#' \dontrun{
#' # Read a CSV and clean column names
#' data <- gcs_read_csv("my-project-data", "raw/customers.csv")
#'
#' # Read a CSV preserving original column names
#' data <- gcs_read_csv("my-project-data", "raw/customers.csv", clean_names = FALSE)
#'
#' # Use with gcs_auth_bucket for authenticated reading
#' gcs_auth_bucket("my-project-data")
#' data <- gcs_read_csv("my-project-data", "processed/sales_2024.csv")
#' }
#'
#' @seealso [arrow::read_csv_arrow()] for reading options,
#'   [janitor::clean_names()] for name cleaning details
#'
#' @importFrom arrow read_csv_arrow
#' @importFrom glue glue
#' @importFrom janitor clean_names
#' @export
gcs_read_csv <- function(bucket, object, clean_names = TRUE) {
  path <- glue::glue("gs://{bucket}/{object}")
  data <- arrow::read_csv_arrow(path)
  if (clean_names) data <- janitor::clean_names(data)
  data
}

#' Write a CSV file to Google Cloud Storage
#'
#' @description
#' Writes a data frame to a CSV file in Google Cloud Storage using the arrow
#' package. Optionally returns metadata about the uploaded object.
#'
#' @details
#' This function uses arrow's CSV writer for efficient writing of data frames
#' to GCS. The file is written directly to the specified GCS path without
#' requiring temporary local storage.
#'
#' When `meta = TRUE`, the function retrieves and returns metadata about the
#' uploaded object including:
#' - The GCS path
#' - MD5 hash for integrity verification
#' - Generation number for versioning
#' - File size
#' - Last updated timestamp
#'
#' @param data A data frame to write to GCS.
#' @param bucket Character string. The name of the GCS bucket to write to.
#' @param object Character string. The destination path for the CSV file within
#'   the bucket (e.g., "folder/subfolder/filename.csv").
#' @param meta Logical. If `TRUE`, returns a list with object metadata. If `FALSE`
#'   (default), returns the GCS path invisibly.
#'
#' @return If `meta = TRUE`, a list containing:
#'   - `path`: The full GCS path to the object
#'   - `md5_hash`: The MD5 hash of the uploaded object
#'   - `generation`: The object's generation number
#'   - `size`: The object size in bytes
#'   - `updated`: The last update timestamp
#'
#'   If `meta = FALSE`, the GCS path (invisibly).
#'
#' @examples
#' \dontrun{
#' # Write a data frame to GCS
#' gcs_write_csv(mtcars, "my-project-data", "output/mtcars.csv")
#'
#' # Write and get metadata back
#' meta <- gcs_write_csv(mtcars, "my-project-data", "output/mtcars.csv", meta = TRUE)
#' print(meta$md5_hash)
#'
#' # Use with authentication
#' gcs_auth_bucket("my-project-data")
#' gcs_write_csv(my_data, "my-project-data", "processed/results.csv")
#' }
#'
#' @seealso [arrow::write_csv_arrow()] for write options,
#'   [googleCloudStorageR::gcs_get_object()] for metadata retrieval
#'
#' @importFrom arrow write_csv_arrow
#' @importFrom googleCloudStorageR gcs_get_object
#' @export
gcs_write_csv <- function(data, bucket, object, meta = FALSE) {
  path <- paste0("gs://", bucket, "/", object)
  arrow::write_csv_arrow(data, path)

  if (meta) {
    metadata <- googleCloudStorageR::gcs_get_object(object, bucket = bucket, meta = TRUE)
    list(
      path = path,
      md5_hash = metadata$md5Hash,
      generation = metadata$generation,
      size = metadata$size,
      updated = metadata$updated
    )
  } else {
    invisible(path)
  }
}

#' List objects in a Google Cloud Storage bucket
#'
#' @description
#' Lists all object names in a GCS bucket, optionally filtered by a prefix.
#' Returns a character vector of object names.
#'
#' @details
#' This function wraps `googleCloudStorageR::gcs_list_objects()` and extracts
#' just the object names as a character vector using dplyr::pull().
#'
#' The prefix parameter can be used to filter results to objects within a
#' specific "folder" or matching a specific pattern. Note that GCS uses a
#' flat namespace, so prefixes simulate directory structures.
#'
#' @param bucket Character string. The name of the GCS bucket to list objects from.
#' @param prefix Character string (optional). A prefix to filter objects. Only
#'   objects whose names begin with this prefix will be returned.
#'
#' @return A character vector of object names in the bucket.
#'
#' @examples
#' \dontrun{
#' # List all objects in a bucket
#' all_objects <- gcs_list_objects("my-project-data")
#'
#' # List objects in a specific "folder"
#' csv_files <- gcs_list_objects("my-project-data", prefix = "raw/")
#'
#' # List objects with a specific prefix
#' sales_files <- gcs_list_objects("my-project-data", prefix = "sales_2024")
#' }
#'
#' @seealso [googleCloudStorageR::gcs_list_objects()] for full object details
#'
#' @importFrom googleCloudStorageR gcs_list_objects
#' @importFrom dplyr pull
#' @export
gcs_list_objects <- function(bucket, prefix = NULL) {
  googleCloudStorageR::gcs_list_objects(bucket = bucket, prefix = prefix) |> dplyr::pull(name)
}

#' Create a targets pipeline target for writing CSVs to GCS
#'
#' @description
#' Creates a targets pipeline target that writes a data frame to Google Cloud
#' Storage as a CSV file. This is a convenience wrapper around targets::tar_target()
#' specifically designed for GCS CSV outputs.
#'
#' @details
#' This function creates a targets target that:
#' 1. Authenticates with GCS using `gcs_auth_bucket()`
#' 2. Writes the data to GCS using `gcs_write_csv()` with metadata enabled
#' 3. Returns the metadata as the target value
#'
#' The target is created with format = "qs" for efficient serialization of
#' the metadata list.
#'
#' The `data` parameter is captured as an expression and evaluated at build time,
#' allowing you to reference upstream targets or other R objects.
#'
#' @param name Symbol. The name of the target (unquoted).
#' @param data Expression. The data frame to write to GCS. Can reference upstream
#'   targets or other R objects.
#' @param bucket Character string. The name of the GCS bucket to write to.
#' @param object Character string. The destination path for the CSV file within
#'   the bucket.
#' @param ... Additional arguments passed to [targets::tar_target()].
#'
#' @return A targets target object suitable for use in a `_targets.R` file.
#'
#' @examples
#' \dontrun{
#' # In your _targets.R file:
#' library(targets)
#' library(ojoutils)
#'
#' tar_plan(
#'   # Process some data
#'   tar_target(raw_data, read_csv("input.csv")),
#'   tar_target(clean_data, clean_my_data(raw_data)),
#'
#'   # Write to GCS as a target
#'   tar_gcs_csv(
#'     gcs_output,
#'     clean_data,
#'     bucket = "my-project-data",
#'     object = "processed/clean_data.csv"
#'   )
#' )
#'
#' # With additional tar_target options
#' tar_gcs_csv(
#'   gcs_output,
#'   processed_data,
#'   bucket = "my-project-data",
#'   object = "output/results.csv",
#'   priority = 1
#' )
#' }
#'
#' @seealso [targets::tar_target()] for general target options,
#'   [gcs_write_csv()] for the underlying write operation
#'
#' @importFrom rlang ensym as_name enexpr expr
#' @importFrom targets tar_target_raw
#' @export
tar_gcs_csv <- function(name, data, bucket, object, ...) {
  name <- rlang::ensym(name)
  name_string <- rlang::as_name(name)

  # Capture the data expression
  data_expr <- rlang::enexpr(data)

  # Build the command expression using rlang
  cmd <- rlang::expr({
    gcs_auth_bucket(!!bucket)
    gcs_write_csv(!!data_expr, !!bucket, !!object, meta = TRUE)
  })

  tar_target_raw(
    name = name_string,
    command = cmd,
    format = "qs",
    ...
  )
}
