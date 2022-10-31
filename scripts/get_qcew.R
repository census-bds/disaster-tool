#==========================================================#
# GET QCEW LQ DATA 
# Cecile Murray
# 2022-10-21
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "blscrapeR",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

bls_key <- Sys.getenv("BLS_KEY")
census_key <- Sys.getenv("CENSUS_API_KEY")

#============================#

# construct list of all FL county FIPS
fl_county <- fips_codes %>% 
  filter(state == 'FL') %>% 
  mutate(stcofips = paste0(state_code, county_code))

# make API calls for all FL counties and bind in long DF
qcew <- map_dfr(
  fl_county$stcofips,
  ~ qcew_api(
    year = 2022,
    quarter = 1,
    slice = "area",
    sliceCode = .
  )
) %>%
  left_join(
    naics_xwalk,
    by = "industry_code"
  ) %>% 
  mutate(area_fips = as.character(area_fips))  # careful with leading 0's in other states
  
# save it as .Rds for convenience
qcew %>% saveRDS("data/QCEW_FL_2022Q1.Rds")