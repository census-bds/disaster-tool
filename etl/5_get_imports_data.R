# ==========================================================#
# GET FOREIGN TRADE IMPORTS DATA 
# Depends: Census API key + internet access
# Cecile Murray
# 2022-11-10
#
# This script pulls 3 imports datasets:
# 1. National import totals by HS6 commodity
# 2. Import totals by port by HS6 commodity
# 3. Names of ports, cleaned so Tableau can geocode them
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

# intermediate file output
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"
PORT_NAMES_FILE <- "tableau/imports_port_totals.csv"

#============================#
# NATIONAL IMPORT TOTALS

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

#============================#
# IMPORTS BY PORT

# imports from ports - VERY SLOW! Like 2+ hours, probably a package issue
raw_imports <- map_dfr(
  natl$I_COMMODITY,
  ~ getCensus(
    name = "timeseries/intltrade/imports/porths",
    key = census_key,
    vars = c(
      "PORT",
      "I_COMMODITY",
      "I_COMMODITY_SDESC",
      "GEN_VAL_MO",
      "GEN_VAL_YR"
    ),
    time = "2022-09",
    I_COMMODITY = .
  )
)
# NOTE: issue parsing I_COMMODITY_LDESC field from json, unreadable string char

raw_imports %>% saveRDS(PORTS_HS_FILE)

#============================#
# NAMES OF PORTS

# port names and total value
ports <- getCensus(
    name = "timeseries/intltrade/imports/porths",
    key = census_key,
    vars = c("PORT",
             "PORT_NAME",
             "GEN_VAL_YR"
    ),
    time = "2022-09"
)

ports %>%
  select(-time) %>% 
  filter(!PORT %in% c("-", "6000", "7070")) %>% # filter out non-geos
  mutate(
    PORT_NAME = if_else(
      str_detect(PORT_NAME, ",.*,"),
      str_remove(PORT_NAME, ","),
      PORT_NAME
    )
  ) %>% 
  separate(PORT_NAME, into = c("CITY", "STATE"), sep = ", ", remove = FALSE) %>% 
  write_csv(PORT_NAMES_FILE)
