library(fastverse)

indicators <- c("lifeex" = "SP.DYN.LE00.IN",
                "gini"   = "SI.POV.GINI",
                "gdp_pc" = "NY.GDP.PCAP.PP.KD",
                "pop"    = "SP.POP.TOTL",
                "pov_ofcl" = "1.0.HCount.Ofcl",
                "pov_intl" = "SI.POV.DDAY",
                "pov_lmic" = "SI.POV.LMIC",
                "pov_umic" = "SI.POV.UMIC")

wdi <- wbstats::wb_data(indicators,
                        start_date = 1990,
                        end_date = 2022) |>
  joyn::merge(wbstats::wb_cachelist$countries,
              by = "iso3c",
              match_type = "m:1",
              keep = "left",
              reportvar = FALSE)

"data/Rtest1" |>
  fs::dir_create(recurse = TRUE) |>
  fs::path("wdi_in1", ext = "Rds") |>
  readr::write_rds(wdi, file = _)

wdi <-
  readr::read_rds("https://github.com/randrescastaneda/pub_data/raw/master/data/Rtest1/wdi_in1.Rds")
