#' Calculate Neighbour Weights
#'
#' Calculates similarity-based weights between countries using the
#' absolute differences in their values across common years. For each
#' country, the top N neighbours with the smallest total differences
#' are selected and their weights are normalized to sum to one.
#'
#' @param data A data frame containing country, year, and value data.
#' @param country_col A character string specifying the name of the
#'   country column.
#' @param year_col A character string specifying the name of the
#'   year column.
#' @param value_col A character string specifying the name of the
#'   value column used to calculate neighbour similarity.
#' @param top_n_neighbor An integer specifying the maximum number of
#'   neighbours to retain for each country.
#'
#' @return A data frame containing:
#'   \itemize{
#'     \item \code{country}: The country for which neighbours are calculated.
#'     \item \code{neighbour_country}: The selected neighbouring country.
#'     \item \code{weight}: The normalized similarity weight of the neighbour.
#'   }
#'
#'   For each country, the returned neighbour weights sum to one.
#'   Countries with smaller total absolute differences receive larger
#'   weights.
#'
#' @examples
#' # Example 1: Calculate weights using GDP values
#' data <- data.frame(
#'   country = rep(c("India", "USA", "UK"), each = 3),
#'   year = rep(2020:2022, 3),
#'   gdp = c(
#'     2700, 2800, 2900,
#'     21000, 21500, 22000,
#'     2800, 2900, 3000
#'   )
#' )
#'
#' calc_neighbor_weights(
#'   data = data,
#'   country_col = "country",
#'   year_col = "year",
#'   value_col = "gdp",
#'   top_n_neighbor = 1
#' )
#'
#' # Example 2: Calculate weights using employment values
#' data <- data.frame(
#'   country = rep(c("India", "France", "Germany", "Italy"), each = 3),
#'   year = rep(2020:2022, 4),
#'   employment = c(
#'     400, 410, 420,
#'     390, 405, 415,
#'     405, 415, 425,
#'     380, 395, 410
#'   )
#' )
#'
#' calc_neighbor_weights(
#'   data = data,
#'   country_col = "country",
#'   year_col = "year",
#'   value_col = "employment",
#'   top_n_neighbor = 2
#' )
#'
#' @export
calc_neighbor_weights <- function(data,
                                  country_col,
                                  year_col,
                                  value_col,
                                  top_n_neighbor) {

  # Check columns
  required_cols <- c(
    country_col,
    year_col,
    value_col
  )

  if (!all(required_cols %in% names(data))) {
    stop("Some required columns are missing in data.")
  }

  # Check duplicate country-year combinations
  if (anyDuplicated(data[c(country_col, year_col)])) {
    stop("Duplicate country-year combinations found in data.")
  }

  countries <- unique(data[[country_col]])

  results <- list()

  for (country in countries) {

    country_data <- data[
      data[[country_col]] == country,
      c(year_col, value_col),
      drop = FALSE
    ]

    names(country_data) <- c(
      year_col,
      "country_value"
    )

    for (neighbour_country in countries) {

      if (country == neighbour_country) {
        next
      }

      neighbour_data <- data[
        data[[country_col]] == neighbour_country,
        c(year_col, value_col),
        drop = FALSE
      ]

      names(neighbour_data) <- c(
        year_col,
        "neighbour_value"
      )

      # Match common years
      matched_data <- merge(
        country_data,
        neighbour_data,
        by = year_col
      )

      # Remove missing values
      matched_data <- matched_data[
        !is.na(matched_data$country_value) &
          !is.na(matched_data$neighbour_value),
        ,
        drop = FALSE
      ]

      # Skip if there are no common non-missing observations
      if (nrow(matched_data) == 0) {
        next
      }

      # Calculate total difference
      difference <- sum(
        abs(
          matched_data$country_value -
            matched_data$neighbour_value
        )
      )

      results[[length(results) + 1]] <- data.frame(
        country = country,
        neighbour_country = neighbour_country,
        difference = difference
      )
    }
  }

  # No valid pairs
  if (length(results) == 0) {
    stop("No valid country-neighbour pairs found.")
  }

  results <- do.call(rbind, results)

  # Initial weights
  results$weight <- 1 / (1 + results$difference)

  # Sort by country, weight, and neighbour name
  results <- results[
    order(
      results$country,
      -results$weight,
      results$neighbour_country
    ),
    ,
    drop = FALSE
  ]

  # Select top N neighbours
  results <- do.call(
    rbind,
    lapply(
      split(results, results$country),
      function(x) {
        head(x, top_n_neighbor)
      }
    )
  )

  # Rescale weights within each country
  results$weight <- ave(
    results$weight,
    results$country,
    FUN = function(x) {
      x / sum(x)
    }
  )

  # Remove rownames
  rownames(results) <- NULL

  # Return final result
  results[
    c(
      "country",
      "neighbour_country",
      "weight"
    )
  ]
}
