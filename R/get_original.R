#' Get Original Values from Status-Coded Data
#'
#' Extracts the original values from a data frame using a status column.
#' Values are retained only when their corresponding status is `"A"`.
#' The status column is removed from the returned data frame.
#'
#' @param data A data frame containing the status column and value columns.
#' @param status_col A character string specifying the name of the status
#'   column.
#' @param value_cols A character vector specifying the names of the value
#'   columns to process.
#'
#' @return A data frame containing the value columns with values retained
#'   only where the corresponding status is `"A"`. The status column is
#'   removed from the returned data frame.
#'
#' @examples
#' # Example 1: Recover original values from a single value column
#' data <- data.frame(
#'   country = c("India", "USA", "UK"),
#'   gdp = c(3000, 25000, 2800),
#'   status = c("A", "C", "X")
#' )
#'
#' get_original(
#'   data = data,
#'   status_col = "status",
#'   value_cols = "gdp"
#' )
#'
#' # Example 2: Recover original values from multiple value columns
#' data <- data.frame(
#'   country = c("India", "USA"),
#'   employed = c(400, 150),
#'   unemployed = c(20, 10),
#'   status = c("AA", "CA")
#' )
#'
#' get_original(
#'   data = data,
#'   status_col = "status",
#'   value_cols = c("employed", "unemployed")
#' )
#'
#' @export
get_original <- function(data,
                         status_col,
                         value_cols) {

  # Check status column
  if (!status_col %in% names(data)) {
    stop("status_col is missing in data.")
  }

  # Check value columns
  if (!all(value_cols %in% names(data))) {
    stop("Some value_cols are missing in data.")
  }

  status <- strsplit(data[[status_col]], "")

  # Check status length matches value columns
  if (any(lengths(status) != length(value_cols))) {
    stop("The length of status values does not match the number of value_cols.")
  }

  # Get original values
  for (i in seq_along(value_cols)) {

    data[[value_cols[i]]] <- mapply(
      function(value, status_value) {
        if (status_value == "A") {
          value
        } else {
          NA
        }
      },
      data[[value_cols[i]]],
      vapply(status, `[`, character(1), i)
    )
  }

  # Remove status column
  data[[status_col]] <- NULL

  data
}
