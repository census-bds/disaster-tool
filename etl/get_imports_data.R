#==========================================================#
# GET FOREIGN TRADE IMPORTS DATA 
# Cecile Murray
# 2022-11-10
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "censusapi",
          "sf",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

# output file paths
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"

# # debug
# porths_endpoint <- "https://api.census.gov/data/timeseries/intltrade/imports/porths"
# 
# 
# req <- httr::GET(porths_endpoint,
#           query = list(
#             key = census_key,
#             get = "PORT,I_COMMODITY,I_COMMODITY_LDESC,GEN_VAL_MO",
#             time = "2022-09",
#             COMM_LVL = "HS6",
#             I_COMMODITY = "200989"
#           )
# )
# req$url
# raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
# jsonlite::validate(httr::content(req, as = "text"))


# US totals of imports by six-digit HS code in September of 2022
natl <- getCensus(
  name = "timeseries/intltrade/imports/hs",
  key = census_key,
  vars = c("I_COMMODITY",
           "I_COMMODITY_SDESC",
           "GEN_VAL_MO",
           "GEN_VAL_YR" 
  ),
  time = "2022-09",
  COMM_LVL = "HS6",
  I_COMMODITY = "*"
)

natl %>% saveRDS(NATL_HS6_FILE)

# imports from ports - SLOW!
raw_imports <- map_dfr(
  natl$I_COMMODITY,
  ~ getCensus(
    name = "timeseries/intltrade/imports/porths",
    key = census_key,
    vars = c("PORT",
             "I_COMMODITY",
             "I_COMMODITY_SDESC", 
             "GEN_VAL_MO",
             "GEN_VAL_YR"
    ),
    time = "2022-09",
    I_COMMODITY = .
  )
)
# NOTE: issue parsing LDESC field from json

raw_imports %>% glimpse()

raw_imports %>% saveRDS(PORTS_HS_FILE)