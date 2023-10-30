library(fastverse)

#' simulate household survey with welfare weights and area
#'
#' welfare is extracted from a lognormal distribution
#'
#' @param size integer number of obs
#' @param mean numeric: mean of distribution
#' @param sd  numeric: standard disrtribution
#' @param wlimit  integer: higher number of sample weights
#'
#' @return data.table
#' @examples
#' svy_sim()
svy_sim <- function(size = 1e5, mean = 3, sd = 5, wlimit = 1e3) {
  weight <- sample(x = wlimit,
                    size = size,
                    replace = TRUE,
                    prob = c(wlimit:1)/wlimit) |>
    sort()

  welfare <-
    rlnorm(size) |>
    fscale(mean = mean, sd = sd) |>
    sort() |>
    replace_outliers(0, 0, single.limit = "min")

  area <- sample(2, size,
                 replace = TRUE,
                 prob = c(.75, .25)) |>
    factor(labels = c("urban", "rural"))


  md <- data.table(welfare = welfare,
                   weight  = weight,
                   area    = area)
  return(md)

}

n <- 10

means <- seq(from = 1,
             to   = 5,
             length.out = n)

sds   <- seq(from = 5,
             to   = 3,
             length.out = n)


l_svy <- purrr::map2(means, sds,
                     .f = \(x,y) {
                       svy_sim(mean = x, sd = y)
                     })

names(l_svy) <- paste0("Y", (c(1:n) + 2000))


"data/Rtest1" |>
  fs::dir_create(recurse = TRUE) |>
  fs::path("svy_sim_in1", ext = "Rds") |>
  readr::write_rds(l_svy, file = _)


