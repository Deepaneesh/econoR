\name{calc_weighted_value}
\alias{calc_weighted_value}
\title{Calculate Weighted Values and Growth Rates}
\description{
Calculates weighted values and growth rates for a country using
neighbouring-country weights. The function can return weighted
growth rates, weighted values, and growth rates of the calculated
weighted values.
}
\usage{
calc_weighted_value(
  weighted_data,
  cal_data,
  data_country_name,
  data_year,
  data_value,
  return_cal_growth_rate = FALSE,
  return_cal_values = FALSE,
  retun_cal_value_growth_rate = FALSE
)
}
\arguments{
\item{weighted_data}{
A data frame containing neighbouring-country weights. It must contain
the columns \code{country}, \code{neighbour_country}, and \code{weight}.
}

\item{cal_data}{
A data frame containing country-level calculation data.
}

\item{data_country_name}{
A character string specifying the country column in \code{cal_data}.
}

\item{data_year}{
A character string specifying the year column in \code{cal_data}.
}

\item{data_value}{
A character string specifying the value column in \code{cal_data}.
}

\item{return_cal_growth_rate}{
Logical. If \code{TRUE}, returns the weighted growth rate of the
neighbouring countries. Default is \code{FALSE}.
}

\item{return_cal_values}{
Logical. If \code{TRUE}, returns the weighted value calculated from
the neighbouring countries. Default is \code{FALSE}.
}

\item{retun_cal_value_growth_rate}{
Logical. If \code{TRUE}, returns the growth rate of the calculated
weighted values. Default is \code{FALSE}.
}
}
\value{
A data frame containing a \code{year} column and the requested
calculated measures.

\itemize{
  \item \code{cal_growth_rate} is the weighted growth rate of
  neighbouring countries when \code{return_cal_growth_rate = TRUE}.

  \item \code{cal_values} is the weighted value of neighbouring
  countries when \code{return_cal_values = TRUE}.

  \item \code{cal_value_growth_rate} is the growth rate of the
  calculated weighted values when
  \code{retun_cal_value_growth_rate = TRUE}.
}
}
\details{
The function uses the weights supplied in \code{weighted_data} to
calculate a weighted value across neighbouring countries for each year.

For weighted growth rates, the year-on-year growth rate is first
calculated separately for each neighbouring country. The resulting
growth rates are then combined using the supplied weights.

For weighted values, the values of the neighbouring countries are
combined using their respective weights. If some neighbouring countries
have missing values for a particular year, only the available values
and their corresponding weights are used.

The weights in \code{weighted_data} must sum to 1.
}
\examples{
weighted_data <- data.frame(
  country = "India",
  neighbour_country = c("China", "Japan"),
  weight = c(0.6, 0.4)
)

cal_data <- data.frame(
  country = rep(c("China", "Japan"), each = 3),
  year = rep(2021:2023, 2),
  gdp = c(100, 110, 121, 80, 84, 88.2)
)

calc_weighted_value(
  weighted_data = weighted_data,
  cal_data = cal_data,
  data_country_name = "country",
  data_year = "year",
  data_value = "gdp",
  return_cal_values = TRUE
)

weighted_data <- data.frame(
  country = "India",
  neighbour_country = c("China", "Japan"),
  weight = c(0.7, 0.3)
)

cal_data <- data.frame(
  country = rep(c("China", "Japan"), each = 4),
  year = rep(2020:2023, 2),
  employment = c(
    100, 105, 110, 115,
    80, 84, 88, 92
  )
)

calc_weighted_value(
  weighted_data = weighted_data,
  cal_data = cal_data,
  data_country_name = "country",
  data_year = "year",
  data_value = "employment",
  return_cal_growth_rate = TRUE,
  return_cal_values = TRUE,
  retun_cal_value_growth_rate = TRUE
)
}
\keyword{economics}
\keyword{data manipulation}
\keyword{weights}
\keyword{growth rates}
