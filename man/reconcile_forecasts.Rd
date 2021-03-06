% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reconcile_forecasts.R
\name{reconcile_forecasts}
\alias{reconcile_forecasts}
\title{Reconcile multiple temporal or hierarchical forecasts}
\usage{
reconcile_forecasts(
  forecasts,
  frequency,
  index,
  outcome,
  keys = NULL,
  method,
  keep_all = TRUE,
  keep_non_reconciled = FALSE
)
}
\arguments{
\item{forecasts}{A list of 2 or more dataframes with forecasts. Each dataframe must have
a date column named \code{index} of class \code{Date} or \code{POSIXt} and a forecast column named
\code{outcome} of class \code{numeric}.
Forecasts should be sorted from oldest (top) to newest (bottom).}

\item{frequency}{A character vector of \code{length(forecasts)} that identifies the date/time frequency
of the forecast. Each string should work with \code{base::seq.Date(..., by = "frequency")} or
\code{base::seq.POSIXt(..., by = "frequency")} e.g., '1 hour', '1 month', '7 days', '10 years' etc.}

\item{index}{A string giving the column name of the date column which should be common across \code{forecasts}.}

\item{outcome}{A string giving the column name of the forecast which should be common across \code{forecasts}.}

\item{keys}{Optional. For forecast reconciliation across groups, a \code{unique()} vector of column names listing all of the keys that
identify a distinct time series across the datasets in \code{forecasts}. If not specified, all columns that are not
in \code{index} or \code{outcome} are treated as grouping keys for each dataset in \code{forecasts}.}

\item{method}{One of \code{c("temporal", "group")}. See the Implementation section for details.}

\item{keep_all}{Boolean. For \code{method = "temporal"}. If \code{TRUE}, reconciled forecasts at all levels are returned.
If \code{FALSE}, only the bottom-level or most disaggregated forecast is returned which can be manually aggregated as needed.}

\item{keep_non_reconciled}{Boolean. For \code{method = "temporal"}. If \code{TRUE}, any additional higher frequency forecasts
that fell outside of the date range of the lowest frequency forecast are returned with their same forecast value from \code{forecasts}.}
}
\value{
A \code{data.frame} of reconciled forecasts.
}
\description{
The purpose of forecast reconciliation is to produce a single coherent forecast
from multiple forecasts produced at (a) different time horizons (e.g., monthly and quarterly)
and/or (b) different levels of aggregation (e.g., classroom, school, and school district).
After forecast reconciliation, the bottom-level or most disaggregated forecast can simply
be summed up to produce all higher-level forecasts.
}
\section{Implementation}{


    \itemize{
      \item \bold{method = 'temporal'}: Forecasts are reconciled across forecast horizons.
        \itemize{
          \item Structural scaling with weights from temporal hierarchies from Athanasopoulos et al. (2017).
          \item To produce correct forecast reconciliations, all forecasts at the lowest/disaggregated
          level should be present for all horizons contained in the forecasts with the higher levels of aggregation
          (e.g., 24 monthly forecasts for 2 annual forecasts or 21 daily forecasts for 3 weekly forecasts).
          }

      \item \bold{method = 'group'}: Forecasts are reconciled across groups independently at each forecast horizon.
        \itemize{
          \item Structural scaling from Hyndman et al. (2011).
          \item A key column is not needed for the forecast at the highest level of aggregation.
          \item Having input forecasts at each level of aggregation is not a requirement.
          For example, forecasts by nation, state, and city could be reconciled with only 2 input
          forecasts: 1 for nation (highest aggregation) and 1 for the combination of nation by state by
          city (lowest/no aggregation) without the 2 intermediate-level forecasts at the state and city levels.
          }
      }
}

\section{References}{


Athanasopoulos, G., Hyndman, R. J., Kourentzes, N., & Petropoulos, F. (2017).
Forecasting with temporal hierarchies. European Journal of Operational Research, 262(1), 60-74.
\url{https://robjhyndman.com/papers/temporalhierarchies.pdf}

Hyndman, R. J., Ahmed, R. A., Athanasopoulos, G., & Shang, H. L. (2011).
Optimal combination forecasts for hierarchical time series. Computational statistics & data analysis, 55(9), 2579-2589.
\url{http://robjhyndman.com/papers/hierarchical}
}

\examples{
#------------------------------------------------------------------------------
# Temporal example 1: 2 forecasts, daily/monthly, 2 forecast periods at highest aggregation.
freq <- c("1 day", "1 month")

data_1_day <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-29"), by = freq[1]),
                         "forecast" = c(rep(5, 31), rep(7, 29)))

data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-1"), by = freq[2]),
                           "forecast" = c(150, 200))

forecasts_reconciled <- reconcile_forecasts(list(data_1_day, data_1_month), freq,
                                            index = "index", outcome = "forecast",
                                            method = "temporal")
#------------------------------------------------------------------------------
# Temporal example 2: 3 forecasts, monthly/4-monthly/annually, 1 forecast period at highest aggregation.
freq <- c("1 month", "4 months", "1 year")

data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-12-1"), by = freq[1]),
                           "forecast" = rep(10, 12))

data_4_months <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-12-1"), by = freq[2]),
                            "forecast" = c(40, 50, 45))

data_1_year <- data.frame("index" = as.Date("2020-01-01"),
                          "forecast" = c(110))

forecasts_reconciled <- reconcile_forecasts(list(data_1_month, data_4_months, data_1_year), freq,
                                            index = "index", outcome = "forecast",
                                            method = "temporal")
#------------------------------------------------------------------------------
# Temporal example 3: 2 forecasts, weekly/monthly, 2 forecast periods at highest aggregation.
freq <- c("1 week", "1 month")

data_1_week <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-3-1"), by = freq[1]),
                          "forecast" = c(rep(3, 5), rep(2, 4)))

data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-1"), by = freq[2]),
                           "forecast" = c(11, 12))

forecasts_reconciled <- reconcile_forecasts(list(data_1_week, data_1_month), freq,
                                            index = "index", outcome = "forecast",
                                            method = "temporal")
#------------------------------------------------------------------------------
# Temporal example 4: 2 forecasts, hourly/daily, 3 forecast periods at highest aggregation.
freq <- c("1 hour", "1 day")
timezone <- "UTC"

data_1_hour <- data.frame("index" = seq(as.POSIXct("2020-01-01 00:00:00", tz = timezone),
                                        as.POSIXct("2020-01-03 23:00:00", tz = timezone),
                                        by = freq[1]),
                          "forecast" = rep(c(3, 5), 72 / 2))

data_1_day <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-1-3"), by = freq[2]),
                         "forecast" = c(90, 100, 105))

forecasts_reconciled <- reconcile_forecasts(list(data_1_hour, data_1_day), freq,
                                            index = "index", outcome = "forecast",
                                            method = "temporal")
#------------------------------------------------------------------------------
# Grouped example 1: 2 forecasts, completely nested/hierarchical.
freq <- c("1 month")

dates <- seq(as.Date("2020-1-1"), as.Date("2020-3-1"), by = freq)

data_total <- data.frame("index" = dates,
                         "forecast" = c(50, 100, 75))

data_state <- data.frame("index" = rep(dates, 2),
                         "state" = c(rep("IL", length(dates)), rep("WI", length(dates))),
                         "forecast" = c(20, 60, 40, 25, 40, 50))

forecasts <- list("total" = data_total, "state" = data_state)

forecasts_reconciled <- reconcile_forecasts(forecasts, freq,
                                            index = "index", outcome = "forecast",
                                            method = "group")
#------------------------------------------------------------------------------
# Grouped example 2: 4 forecasts, non-nested.
freq <- c("1 month")

dates <- seq(as.Date("2020-1-1"), as.Date("2020-3-1"), by = freq)

data_total <- data.frame("index" = dates,
                         "forecast" = c(50, 100, 75))

data_state <- data.frame("index" = rep(dates, 2),
                         "state" = c(rep("IL", length(dates)), rep("WI", length(dates))),
                         "forecast" = c(20, 60, 40, 25, 40, 50))

data_sex <- data.frame("index" = rep(dates, 2),
                       "sex" = c(rep("M", length(dates)), rep("F", length(dates))),
                       "forecast" = c(25, 45, 40, 35, 40, 20))

data_state_sex <- data.frame("index" = rep(dates, 4),
                             "state" = c(rep("IL", length(dates)*2), rep("WI", length(dates)*2)),
                             "sex" = c(rep("M", 3), rep("F", 3), rep("M", 3), rep("F", 3)),
                             "forecast" = c(5, 15, 10, 30, 10, 10, 25, 30, 20, 10, 10, 15))

forecasts <- list("total" = data_total, "state" = data_state,
                  "sex" = data_sex, "state_sex" = data_state_sex)

forecasts_reconciled <- reconcile_forecasts(forecasts, freq,
                                            index = "index", outcome = "forecast",
                                            method = "group")
}
