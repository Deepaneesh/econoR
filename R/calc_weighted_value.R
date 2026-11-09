#' Calculate Weighted Values and Growth Rates
#'
#' Calculates weighted values and growth rates for a country using
#' neighbouring-country weights. The function can return weighted
#' growth rates, weighted values, and growth rates of the calculated
#' weighted values.
#'
#' @param weighted_data A data frame containing neighbouring-country
#'   weights. It must contain the columns `country`,
#'   `neighbour_country`, and `weight`.
#' @param cal_data A data frame containing country-level calculation
#'   data.
#' @param data_country_name A character string specifying the country
#'   column in `cal_data`.
#' @param data_year A character string specifying the year column in
#'   `cal_data`.
#' @param data_value A character string specifying the value column in
#'   `cal_data`.
#' @param return_cal_growth_rate Logical. If `TRUE`, returns the
#'   weighted growth rate of the neighbouring countries. Default is
#'   `FALSE`.
#' @param return_cal_values Logical. If `TRUE`, returns the weighted
#'   value calculated from the neighbouring countries. Default is
#'   `FALSE`.
#' @param retun_cal_value_growth_rate Logical. If `TRUE`, returns the
#'   growth rate of the calculated weighted values. Default is `FALSE`.
#'
#' @return A data frame containing a `year` column and the requested
#'   calculated measures:
#'   \itemize{
#'     \item `cal_growth_rate` - weighted growth rate of neighbouring
#'       countries, when `return_cal_growth_rate = TRUE`.
#'     \item `cal_values` - weighted values of neighbouring countries,
#'       when `return_cal_values = TRUE`.
#'     \item `cal_value_growth_rate` - growth rate of the calculated
#'       weighted values, when
#'       `retun_cal_value_growth_rate = TRUE`.
#'   }
#'
#' @details
#' The function uses the weights supplied in `weighted_data` to
#' calculate a weighted value across neighbouring countries for each
#' year.
#'
#' For weighted growth rates, the year-on-year growth rate is first
#' calculated separately for each neighbouring country. The resulting
#' growth rates are then combined using the supplied weights.
#'
#' For weighted values, the values of the neighbouring countries are
#' combined using their respective weights. If some neighbouring
#' countries have missing values for a particular year, only the
#' available values and their corresponding weights are used.
#'
#' The weights in `weighted_data` must sum to 1.
#'
#' @examples
#' # Example 1: Calculate weighted values
#' weighted_data <- data.frame(
#'   country = "India",
#'   neighbour_country = c("China", "Japan"),
#'   weight = c(0.6, 0.4)
#' )
#'
#' cal_data <- data.frame(
#'   country = rep(c("China", "Japan"), each = 3),
#'   year = rep(2021:2023, 2),
#'   gdp = c(100, 110, 121, 80, 84, 88.2)
#' )
#'
#' calc_weighted_value(
#'   weighted_data = weighted_data,
#'   cal_data = cal_data,
#'   data_country_name = "country",
#'   data_year = "year",
#'   data_value = "gdp",
#'   return_cal_values = TRUE
#' )
#'
#' # Example 2: Calculate weighted values and growth rates
#' weighted_data <- data.frame(
#'   country = "India",
#'   neighbour_country = c("China", "Japan"),
#'   weight = c(0.7, 0.3)
#' )
#'
#' cal_data <- data.frame(
#'   country = rep(c("China", "Japan"), each = 4),
#'   year = rep(2020:2023, 2),
#'   employment = c(
#'     100, 105, 110, 115,
#'     80, 84, 88, 92
#'   )
#' )
#'
#' calc_weighted_value(
#'   weighted_data = weighted_data,
#'   cal_data = cal_data,
#'   data_country_name = "country",
#'   data_year = "year",
#'   data_value = "employment",
#'   return_cal_growth_rate = TRUE,
#'   return_cal_values = TRUE,
#'   retun_cal_value_growth_rate = TRUE
#' )
#'
#' @export
calc_weighted_value <- function(weighted_data,
                                cal_data,
                                data_country_name,
                                data_year,
                                data_value,
                                return_cal_growth_rate = FALSE,
                                return_cal_values = FALSE,
                                retun_cal_value_growth_rate = FALSE) {

  # Check required columns in weighted data
  if (!all(c("country", "neighbour_country", "weight") %in%
           names(weighted_data))) {
    stop(
      "weighted_data must contain country, neighbour_country, and weight."
    )
  }

  # Check required columns in calculation data
  if (!all(c(
    data_country_name,
    data_year,
    data_value
  ) %in% names(cal_data))) {
    stop("Some required columns are missing in cal_data.")
  }

  # Check NA values in data_value
  if (anyNA(cal_data[[data_value]])) {
    stop("The data_value column must not contain any NA values.")
  }

  # Check that weighted data contains only one country
  countries <- unique(weighted_data$country)

  if (length(countries) != 1) {
    stop("weighted_data must contain only one country.")
  }

  # Check weights sum to 1
  if (!isTRUE(all.equal(
    sum(weighted_data$weight, na.rm = TRUE),
    1
  ))) {
    stop("The sum of weights must be equal to 1.")
  }

  # Select neighbouring countries
  neighbour_countries <- weighted_data$neighbour_country

  neighbour_data <- cal_data[
    cal_data[[data_country_name]] %in% neighbour_countries,
    c(data_country_name, data_year, data_value),
    drop = FALSE
  ]

  # Check that all neighbours are available
  available_countries <- unique(
    neighbour_data[[data_country_name]]
  )

  if (!all(neighbour_countries %in% available_countries)) {
    missing_countries <- neighbour_countries[
      !neighbour_countries %in% available_countries
    ]

    stop(
      paste(
        "The following neighbouring countries are missing from cal_data:",
        paste(missing_countries, collapse = ", ")
      )
    )
  }

  # Rename columns
  names(neighbour_data) <- c(
    "country",
    "year",
    "value"
  )

  # Pivot wider
  value_data <- reshape(
    neighbour_data,
    idvar = "year",
    timevar = "country",
    direction = "wide"
  )

  # Remove "value." prefix
  names(value_data)[-1] <- sub(
    "^value\\.",
    "",
    names(value_data)[-1]
  )

  # Sort by year
  value_data <- value_data[
    order(value_data$year),
    ,
    drop = FALSE
  ]

  # Create result
  result <- data.frame(
    year = value_data$year
  )

  # Calculate weighted growth rate
  if (return_cal_growth_rate) {

    growth_data <- value_data

    for (country in neighbour_countries) {

      if (country %in% names(growth_data)) {

        growth_data[[country]] <- c(
          NA,
          diff(growth_data[[country]]) /
            head(growth_data[[country]], -1) * 100
        )
      }
    }

    weighted_growth <- numeric(nrow(growth_data))

    for (i in seq_len(nrow(growth_data))) {

      values <- numeric(0)
      weights <- numeric(0)

      for (j in seq_len(nrow(weighted_data))) {

        country <- weighted_data$neighbour_country[j]
        weight <- weighted_data$weight[j]

        value <- growth_data[[country]][i]

        if (!is.na(value)) {
          values <- c(values, value)
          weights <- c(weights, weight)
        }
      }

      if (length(values) == 0) {
        weighted_growth[i] <- NA
      } else {
        weighted_growth[i] <-
          sum(values * weights) / sum(weights)
      }
    }

    result$cal_growth_rate <- weighted_growth
  }

  # Calculate weighted values
  if (return_cal_values ||
      retun_cal_value_growth_rate) {

    weighted_values <- numeric(nrow(value_data))

    for (i in seq_len(nrow(value_data))) {

      values <- numeric(0)
      weights <- numeric(0)

      for (j in seq_len(nrow(weighted_data))) {

        country <- weighted_data$neighbour_country[j]
        weight <- weighted_data$weight[j]

        value <- value_data[[country]][i]

        if (!is.na(value)) {
          values <- c(values, value)
          weights <- c(weights, weight)
        }
      }

      if (length(values) == 0) {
        weighted_values[i] <- NA
      } else {
        weighted_values[i] <-
          sum(values * weights) / sum(weights)
      }
    }
  }

  # Return weighted values
  if (return_cal_values) {
    result$cal_values <- weighted_values
  }

  # Calculate growth rate of weighted values
  if (retun_cal_value_growth_rate) {

    result$cal_value_growth_rate <- c(
      NA,
      diff(weighted_values) /
        head(weighted_values, -1) * 100
    )
  }

  result
}
