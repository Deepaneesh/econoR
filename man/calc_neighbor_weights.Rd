\name{calc_neighbor_weights}
\alias{calc_neighbor_weights}
\title{Calculate Neighbour Weights}
\description{
Calculates similarity-based weights between countries using the
absolute differences in their values across common years. For each
country, the top N neighbours with the smallest total differences
are selected and their weights are normalized to sum to one.
}

\usage{
calc_neighbor_weights(
  data,
  country_col,
  year_col,
  value_col,
  top_n_neighbor
)
}

\arguments{
\item{data}{
A data frame containing country, year, and value data.
}

\item{country_col}{
A character string specifying the name of the country column.
}

\item{year_col}{
A character string specifying the name of the year column.
}

\item{value_col}{
A character string specifying the name of the value column used to
calculate neighbour similarity.
}

\item{top_n_neighbor}{
An integer specifying the maximum number of neighbours to retain
for each country.
}
}

\value{
A data frame containing the following columns:

\itemize{
\item \code{country}: The country for which neighbours are calculated.
\item \code{neighbour_country}: The selected neighbouring country.
\item \code{weight}: The normalized similarity weight of the neighbour.
}

For each country, the returned neighbour weights sum to one.
Countries with smaller total absolute differences receive larger
weights.
}

\examples{

# Example 1: Calculate weights using GDP values

data <- data.frame(
  country = rep(c("India", "USA", "UK"), each = 3),
  year = rep(2020:2022, 3),
  gdp = c(
    2700, 2800, 2900,
    21000, 21500, 22000,
    2800, 2900, 3000
  )
)

calc_neighbor_weights(
  data = data,
  country_col = "country",
  year_col = "year",
  value_col = "gdp",
  top_n_neighbor = 1
)


# Example 2: Calculate weights using employment values

data <- data.frame(
  country = rep(c("India", "France", "Germany", "Italy"), each = 3),
  year = rep(2020:2022, 4),
  employment = c(
    400, 410, 420,
    390, 405, 415,
    405, 415, 425,
    380, 395, 410
  )
)

calc_neighbor_weights(
  data = data,
  country_col = "country",
  year_col = "year",
  value_col = "employment",
  top_n_neighbor = 2
)

}

\author{
Deepaneesh
}
