\name{get_original}
\alias{get_original}
\title{Get Original Values from Status-Coded Data}
\description{
Extracts the original values from a data frame using a status column.
Values are retained only when their corresponding status is
\code{"A"}. The status column is removed from the returned data frame.
}

\usage{
get_original(data, status_col, value_cols)
}

\arguments{
\item{data}{
A data frame containing the status column and value columns.
}

\item{status_col}{
A character string specifying the name of the status column.
}

\item{value_cols}{
A character vector specifying the names of the value columns to
process.
}
}

\value{
A data frame containing the value columns with values retained only
where the corresponding status is \code{"A"}. The status column is
removed from the returned data frame.
}

\examples{

# Example 1: Recover original values from a single value column

data <- data.frame(
  country = c("India", "USA", "UK"),
  gdp = c(3000, 25000, 2800),
  status = c("A", "C", "X")
)

get_original(
  data = data,
  status_col = "status",
  value_cols = "gdp"
)


# Example 2: Recover original values from multiple value columns

data <- data.frame(
  country = c("India", "USA"),
  employed = c(400, 150),
  unemployed = c(20, 10),
  status = c("AA", "CA")
)

get_original(
  data = data,
  status_col = "status",
  value_cols = c("employed", "unemployed")
)

}

\author{
Deepaneesh
}
