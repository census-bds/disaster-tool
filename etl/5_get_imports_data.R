# ==========================================================#
# GET FOREIGN TRADE IMPORTS DATA 
# Depends: Census API key + internet access
# Cecile Murray
# 2022-11-10
#
# This script does 4 things:
# 1. National import totals by HS6 commodity
# 2. Import totals by port by HS6 commodity
# 3. Pull names of ports and cleans them so Tableau can 
#    geocode them
# 4. Compute % of national commodity coming through each 
#    port 
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

# output for local R files
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"

# output for tableau
PORT_NAMES_FILE <- "tableau/imports_port_totals.csv"
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

#============================#
# STATISTICS FOR TABLEAU  

# if needed, option to read data in instead of pulling from API if this
# is a re-run
# natl <- readRDS(NATL_HS6_FILE) 
# raw_imports <- readRDS(PORTS_HS6_FILE)
# ports <- read_csv(PORT_NAMES_FILE)
 

# compute the share of products coming in through each port from national total 
# in Sept and year to date

port_shares <- raw_imports %>% 
  left_join(
    natl,
    suffix = c("_port", ""),
    by = c(
      "I_COMMODITY",
      "I_COMMODITY_SDESC",
      "I_COMMODITY_1",
      "time"
    )
  ) %>%
  left_join(
    ports %>% select(-GEN_VAL_YR),
    by = "PORT"
  ) %>% 
  mutate_at(
    vars(contains("GEN_VAL")),
    ~ as.numeric(.)
  ) %>% 
  # doing this if_else to handle 0 / 0
  mutate(
    port_share_mo = if_else( 
      GEN_VAL_MO_port == 0 & GEN_vAL_MO == 0,
      0,
      GEN_VAL_MO_port / GEN_VAL_MO * 100
    ),
    port_share_yr = if_else( 
      GEN_VAL_YR_port == 0 & GEN_vAL_YR == 0,
      0,
      GEN_VAL_YR_port / GEN_VAL_YR * 100
    )
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
  write_csv(PORT_SHARES_PATH)
