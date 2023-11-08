library(fastverse)

start_date <- 1990
end_date <- 2022
pov_lines <- c(2.15, 3.65, 6.85)


pip <-
 purrr::map(pov_lines,
    \(x) pipr::get_stats(fill_gaps = TRUE,
         povline = x),
    .progress = TRUE) |>
 rowbind() |>
 fsubset(reporting_level == "national") |>
 fselect(iso3c = country_code,
   date = year,
   poverty_line,
   headcount) |>
 fmutate(poverty_line = paste0("pl_", poverty_line)) |>
 pivot(how = "wider",
  ids = c("iso3c", "date"),
  values = "headcount",
  names = "poverty_line") |>
 setDT()

plvars <- grep("^pl", names(pip), value = TRUE)
plnew <- c("pov_intl", "pov_lmic", "pov_umic")

setnames(pip, plvars, plnew)


indicators <- c("lifeex" = "SP.DYN.LE00.IN",
    "gini" = "SI.POV.GINI",
    "gdp" = "NY.GDP.MKTP.PP.KD",
    "pop" = "SP.POP.TOTL",
    "pov_ofcl" = "1.0.HCount.Ofcl")

wdi <- wbstats::wb_data(indicators,
      start_date = start_date,
      end_date = end_date) |>
 joyn::merge(wbstats::wb_cachelist$countries,
    by = "iso3c",
    match_type = "m:1",
    keep = "left",
    reportvar = FALSE) |>
 joyn::merge(pip,
    by = c("iso3c", "date"),
    match_type = "1:1",
    keep = "inner",
    reportvar = FALSE) |>
  fselect(
    region,
    iso3c,
    date,
    country,
    pov_ofcl,
    gdp,
    gini,
    lifeex,
    pop,
    pov_intl,
    pov_lmic,
    pov_umic
  ) |>
  ftransform(gdp = gdp/1e6)

setrelabel(wdi,
           region   = "region",
           iso3c    = "ISO3 country code",
           date     = "year",
           country  = "country name",
           gdp      = "GDP, PPP (2017 prices [in millions])",
           pov_intl = "Poverty headcount at $2.15 (2017 prices)",
           pov_lmic = "Poverty headcount at $3.65 (2017 prices)",
           pov_umic = "Poverty headcount at $6.85 (2017 prices)")
namlab(wdi)

"data/Rtest1" |>
 fs::dir_create(recurse = TRUE) |>
 fs::path("wdi_in1", ext = "Rds") |>
 readr::write_rds(wdi, file = _)


# Test it is workinf
# wdi2 <-
# readr::read_rds("https://github.com/randrescastaneda/pub_data/raw/test3/data/Rtest1/wdi_in1.Rds")
#
#
# waldo::compare(wdi, wdi2)



