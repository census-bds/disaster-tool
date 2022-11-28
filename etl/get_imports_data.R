# ==========================================================#
# GET FOREIGN TRADE IMPORTS DATA 
# Cecile Murray
# 2022-11-10
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          # "janitor",
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
PORT_NAMES_FILE <- "tableau/imports_port_names.csv"

# # debug
# porths_endpoint <- "https://api.census.gov/data/timeseries/intltrade/imports/porths"
# 
# 
# req <- httr::GET(porths_endpoint,
#           query = list(
#             key = census_key,
#             get = "PORT,I_COMMODITY,I_COMMODITY_LDESC,GEN_VAL_MO",
            time = "2022-09",
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

# # imports from ports - SLOW!
# raw_imports <- map_dfr(
#   natl$I_COMMODITY,
#   ~ getCensus(
#     name = "timeseries/intltrade/imports/porths",
#     key = census_key,
#     vars = c("PORT",
#     "I_COMMODITY",
#              "I_COMMODITY_SDESC", 
#              "GEN_VAL_MO",
#              "GEN_VAL_YR"
#     ),
#     time = "2022-09",
#     I_COMMODITY = .
#   )
# )
# # NOTE: issue parsing LDESC field from json

raw_imports %>% glimpse()

raw_imports %>% saveRDS(PORTS_HS_FILE)

# port names
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
