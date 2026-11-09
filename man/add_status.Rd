\name{add_status}
\alias{add_status}
\title{Add Status to Estimated Data}
\description{
Adds a status code to each row of estimated data by comparing its
identifier and value columns with the corresponding row in the
original data.
}
\usage{
add_status(original_data, estimated_data, id_cols, value_cols)
}
\arguments{
\item{original_data}{
A data frame containing the original observations.
}

\item{estimated_data}{
A data frame containing the estimated observations.
}

\item{id_cols}{
A character vector containing the columns used to identify
observations or groups.
}

\item{value_cols}{
A character vector containing the columns whose values should be
compared between the original and estimated data.
}
}
\value{
A data frame containing \code{estimated_data} with an additional
\code{status} column.

The status is created for each value column using the following codes:

\itemize{
\item \code{A}: The estimated value and original value are both available.
\item \code{C}: The estimated value is available but the original value is missing.
\item \code{X}: The estimated value is missing.
}

When multiple value columns are supplied, the status codes are combined
into a single character string in the order of \code{value_cols}.
}
\examples{
# Example 1: Compare original and estimated data
original_data <- data.frame(
  country = c("India", "USA"),
  year = c(2020, 2020),
  gdp = c(2671, NA)
)

estimated_data <- data.frame(
  country = c("India", "USA"),
  year = c(2020, 2020),
  gdp = c(2800, 21000)
)

add_status(
  original_data = original_data,
  estimated_data = estimated_data,
  id_cols = c("country", "year"),
  value_cols = "gdp"
)

# Example 2: Compare multiple value columns
original_data <- data.frame(
  country = c("India", "USA"),
  year = c(2020, 2020),
  employed = c(400, NA),
  unemployed = c(20, 10)
)

estimated_data <- data.frame(
  country = c("India", "USA"),
  year = c(2020, 2020),
  employed = c(410, 150),
  unemployed = c(21, NA)
)

add_status(
  original_data = original_data,
  estimated_data = estimated_data,
  id_cols = c("country", "year"),
  value_cols = c("employed", "unemployed")
)
}
\author{
Deepaneesh
}
