% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_health_region.R
\name{read_health_region}
\alias{read_health_region}
\title{Download official data of Brazilian health regions as an sf object.}
\usage{
read_health_region(year = 2013, simplified = TRUE, showProgress = TRUE, tp)
}
\arguments{
\item{year}{Year of the data (defaults to 2013, latest available)}

\item{simplified}{Logic FALSE or TRUE, indicating whether the function returns the
data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
For spatial analysis and statistics users should set simplified = FALSE. Borders have been
simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.}

\item{showProgress}{Logical. Defaults to (TRUE) display progress bar}

\item{tp}{Argument deprecated. Please use argument 'simplified'}
}
\description{
Download official data of Brazilian health regions as an sf object.
}
\examples{
\donttest{

library(geobr)

# Read all health regions for a given year
  hr <- read_health_region( year=2013)

}

}
\seealso{
Other general area functions: 
\code{\link{read_amazon}()},
\code{\link{read_biomes}()},
\code{\link{read_census_tract}()},
\code{\link{read_conservation_units}()},
\code{\link{read_country}()},
\code{\link{read_immediate_region}()},
\code{\link{read_intermediate_region}()},
\code{\link{read_meso_region}()},
\code{\link{read_micro_region}()},
\code{\link{read_municipality}()},
\code{\link{read_neighborhood}()},
\code{\link{read_region}()},
\code{\link{read_semiarid}()},
\code{\link{read_state}()},
\code{\link{read_statistical_grid}()},
\code{\link{read_weighting_area}()}
}
\concept{general area functions}