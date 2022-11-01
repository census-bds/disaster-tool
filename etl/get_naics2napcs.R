#==========================================================#
# GET ECON CENSUS DATA 
# Cecile Murray
# 2022-10-24
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "NAPCS2017_LABEL", "TVALLN"),
  region = "state:*",
  vintage = 2017,
  key = census_key
)

fl_econ_census <- econ_census %>% 
  filter(state == "12")

naics2napcs <- fl_econ_census %>% 
  filter(str_length(NAICS2017) == 6) %>% 
  group_by(NAICS2017) %>% 
  mutate(
    TVALLN = as.numeric(TVALLN),
    naics_sum = sum(TVALLN, na.rm=TRUE),
    napcs_ct = n(),
    napcs_share = TVALLN / naics_sum
  ) %>% 
  ungroup() %>% 
  left_join(
    naics_xwalk,
    by = c("NAICS2017" = "industry_code")
  ) %>% 
  select(
    NAICS2017,
    industry_title,
    everything(),
    -state,
    -GEO_ID,
  )

econ_census %>% 
  distinct(NAICS2017) %>%
  left_join(naics_xwalk, by = c("NAICS2017" = "industry_code")) %>% 
  arrange(NAICS2017)
