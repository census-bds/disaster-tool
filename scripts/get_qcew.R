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
)

#============================#

# explore the data
qcew %>% 
  select(
    area_fips,
    industry_code,
    agglvl_code,
    disclosure_code,
    qtrly_estabs,
    lq_qtrly_estabs
  ) %>% 
  filter(agglvl_code == 78) %>% # six digit NAICS
  group_by(area_fips) %>% 
  mutate(
    max_lq_qtrly_estabs = max(lq_qtrly_estabs),
    is_max = if_else(lq_qtrly_estabs == max_lq_qtrly_estabs, 1, 0)
  ) %>% 
  filter(is_max == 1) %>% 
  glimpse()
