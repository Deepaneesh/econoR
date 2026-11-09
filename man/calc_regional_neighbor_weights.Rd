\name{calc_regional_neighbor_weights}
\alias{calc_regional_neighbor_weights}
\title{Calculate Regional Neighbour Weights}
\description{
Calculates similarity-based neighbour weights within each region.
Countries are compared only with other countries belonging to the
same region. The calculation is performed using
\code{calc_neighbor_weights()} for each region.
}

\usage{
calc_regional_neighbor_weights(
  data,
  country_col,
  year_col,
  value_col,
  top_n_neighbor,
  region_col
)
}

\arguments{
\item{data}{
A data frame containing region, country, year, and value data.
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
for each country within its region.
}

\item{region_col}{
A character string specifying the name of the region column.
}
}

\value{
A data frame containing the following columns:

\itemize{
\item \code{region_col}: The region containing the country.
\item \code{country}: The country for which neighbours are calculated.
\item \code{neighbour_country}: The selected neighbouring country.
\item \code{weight}: The normalized similarity weight of the neighbour.
}

Neighbours are selected only from within the same region. The weights
for each country sum to one when valid neighbours are available.
}

\examples{

# Example 1: Calculate regional neighbour weights using GDP

data <- data.frame(
  region = rep(c("Asia", "Europe"), each = 6),
  country = c(
    rep(c("India", "China"), each = 3),
    rep(c("France", "Germany"), each = 3)
  ),
  year = rep(2020:2022, 4),
  gdp = c(
    2700, 2800, 2900,
    14000, 14500, 15000,
    2700, 2800, 2900,
    3800, 3900, 4000
  )
)

calc_regional_neighbor_weights(
  data = data,
  country_col = "country",
  year_col = "year",
  value_col = "gdp",
  top_n_neighbor = 1,
  region_col = "region"
)


# Example 2: Calculate regional neighbour weights using employment

data <- data.frame(
  region = rep(c("Asia", "Europe"), each = 9),
  country = c(
    rep(c("India", "China", "Japan"), each = 3),
    rep(c("France", "Germany", "Italy"), each = 3)
  ),
  year = rep(2020:2022, 6),
  employment = c(
    400, 410, 420,
    420, 430, 440,
    390, 400, 410,
    300, 310, 320,
    305, 315, 325,
    290, 300, 310
  )
)

calc_regional_neighbor_weights(
  data = data,
  country_col = "country",
  year_col = "year",
  value_col = "employment",
  top_n_neighbor = 2,
  region_col = "region"
)

}

\author{
Deepaneesh
}
