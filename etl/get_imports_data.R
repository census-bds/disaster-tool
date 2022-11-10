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


# US totals of imports by six-digit HS code in September of 2022
natl <- getCensus(
  name = "timeseries/intltrade/imports/hs",
  key = census_key,
  vars = c("I_COMMODITY",
           "I_COMMODITY_SDESC",
           "GEN_VAL_MO"
  ),
  time = "2022-09",
  COMM_LVL = "HS6",
  I_COMMODITY = "*"
)


# imports from ports?
# seems to be a parsing issue with censusapi. see if I can resolve?
raw_imports <- map_dfr(
  natl$I_COMMODITY,  
  ~ getCensus(
    name = "timeseries/intltrade/imports/porths",
    key = census_key,
    vars = c("PORT",
             "I_COMMODITY",
             "I_COMMODITY_LDESC",
             "I_COMMODITY_SDESC",
             "GEN_VAL_MO",
             "GEN_VAL_YR"
    ),
    time = "2022-09",
    I_COMMODITY = .
  )
)
