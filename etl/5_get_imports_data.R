# ==========================================================#
# GET FOREIGN TRADE IMPORTS DATA 
# Depends: Census API key + internet access
# Cecile Murray
# 2022-11-10
#
# This script exports three datasets:
# 1. National import totals by HS6 commodity
# 2. Import totals by port by HS6 commodity
# 3. Pull names of ports and cleans them so Tableau can 
#    geocode them
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "here",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

# output for local R files
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"

# output for tableau
PORT_NAMES_FILE <- "tableau/imports_port_names.csv"
PORT_SHARES_PATH <- "tableau/import_port_share.csv"

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

# port names because I didn't pull them in the 
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

#============================#
# STATISTICS FOR TABLEAU  

# compute the share of products coming in through each port from national total 
# in Sept and year to date

port_shares <- raw_imports %>% 
  left_join(
    natl_imports,
    suffix = c("_port", ""),
    by = c(
      "I_COMMODITY",
      "I_COMMODITY_SDESC",
      "I_COMMODITY_1",
      "time"
    )
  ) %>%
  left_join(
    ports_xwalk %>% select(-GEN_VAL_YR),
    by = "PORT"
  ) %>% 
  mutate_at(
    vars(contains("GEN_VAL")),
    ~ as.numeric(.)
  ) %>% 
  mutate(
    port_share_mo = GEN_VAL_MO_port / GEN_VAL_MO * 100,
    port_share_yr = GEN_VAL_YR_port / GEN_VAL_YR * 100,
  ) 

# export for tableau
port_shares %>% 
  filter(PORT != "-") %>%
  select(
    PORT,
    PORT_NAME,
    CITY,
    STATE,
    I_COMMODITY,
    I_COMMODITY_SDESC,
    contains("GEN_VAL"),
    contains("_share_")
  ) %>%
  group_by(PORT) %>% 
  mutate(
    max_share_year = if_else(max(port_share_yr) == port_share_yr, 1, 0),
    max_share_mo = if_else(max(port_share_mo) == port_share_mo, 1, 0),
  ) %>% 
  filter(max_share_year == 1) %>% 
  write_csv(PORT_SHARES_PATH)