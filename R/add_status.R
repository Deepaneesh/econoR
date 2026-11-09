#' Add Status to Estimated Data
#'
#' Adds a status code to each row of estimated data by comparing its
#' identifier and value columns with the corresponding row in the
#' original data.
#'
#' @param original_data A data frame containing the original observations.
#' @param estimated_data A data frame containing the estimated observations.
#' @param id_cols A character vector containing the columns used to identify
#'   observations or groups.
#' @param value_cols A character vector containing the columns whose values
#'   should be compared between the original and estimated data.
#'
#' @return A data frame containing `estimated_data` with an additional
#'   `status` column. The status is created for each row based on the
#'   availability of the original and estimated values:
#'   \itemize{
#'     \item \code{A}: The estimated value and original value are both available.
#'     \item \code{C}: The estimated value is available but the original value
#'       is missing.
#'     \item \code{X}: The estimated value is missing.
#'   }
#'   When multiple value columns are supplied, the status codes are combined
#'   into a single character string in the order of `value_cols`.
#'
#' @examples
#' # Example 1: Compare original and estimated data
#' original_data <- data.frame(
#'   country = c("India", "USA"),
#'   year = c(2020, 2020),
#'   gdp = c(2671, NA)
#' )
#'
#' estimated_data <- data.frame(
#'   country = c("India", "USA"),
#'   year = c(2020, 2020),
#'   gdp = c(2800, 21000)
#' )
#'
#' add_status(
#'   original_data = original_data,
#'   estimated_data = estimated_data,
#'   id_cols = c("country", "year"),
#'   value_cols = "gdp"
#' )
#'
#' # Example 2: Compare multiple value columns
#' original_data <- data.frame(
#'   country = c("India", "USA"),
#'   year = c(2020, 2020),
#'   employed = c(400, NA),
#'   unemployed = c(20, 10)
#' )
#'
#' estimated_data <- data.frame(
#'   country = c("India", "USA"),
#'   year = c(2020, 2020),
#'   employed = c(410, 150),
#'   unemployed = c(21, NA)
#' )
#'
#' add_status(
#'   original_data = original_data,
#'   estimated_data = estimated_data,
#'   id_cols = c("country", "year"),
#'   value_cols = c("employed", "unemployed")
#' )
#'
#' @export
add_status <- function(original_data,
                       estimated_data,
                       id_cols,
                       value_cols) {

  # Check ID columns
  if (!all(id_cols %in% names(original_data))) {
    stop("Some id_cols are missing in original_data.")
  }

  if (!all(id_cols %in% names(estimated_data))) {
    stop("Some id_cols are missing in estimated_data.")
  }

  # Check value columns
  if (!all(value_cols %in% names(original_data))) {
    stop("Some value_cols are missing in original_data.")
  }

  if (!all(value_cols %in% names(estimated_data))) {
    stop("Some value_cols are missing in estimated_data.")
  }

  # Create keys
  original_key <- do.call(
    paste,
    c(original_data[id_cols], sep = "\r")
  )

  estimated_key <- do.call(
    paste,
    c(estimated_data[id_cols], sep = "\r")
  )

  # Check all groups in estimated_data exist in original_data
  if (any(!estimated_key %in% original_key)) {
    stop("Some groups in estimated_data are not available in original_data.")
  }

  # Check all groups in original_data exist in estimated_data
  if (any(!original_key %in% estimated_key)) {
    stop("Some groups in original_data are not available in estimated_data.")
  }

  original_index <- match(
    estimated_key,
    original_key
  )

  # Create status
  status <- sapply(seq_len(nrow(estimated_data)), function(i) {

    original_values <- unlist(
      original_data[
        original_index[i],
        value_cols,
        drop = FALSE
      ]
    )

    estimated_values <- unlist(
      estimated_data[i, value_cols, drop = FALSE]
    )

    paste0(
      ifelse(
        !is.na(estimated_values),
        ifelse(
          !is.na(original_values),
          "A",
          "C"
        ),
        "X"
      ),
      collapse = ""
    )
  })

  estimated_data$status <- status

  estimated_data
}
