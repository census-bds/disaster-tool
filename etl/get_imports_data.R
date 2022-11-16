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


# debug
porths_endpoint <- "https://api.census.gov/data/timeseries/intltrade/imports/porths"


req <- httr::GET(porths_endpoint,
          query = list(
            key = census_key,
            get = "PORT,I_COMMODITY,I_COMMODITY_LDESC,GEN_VAL_MO",
            time = "2022-09",
            COMM_LVL = "HS6",
            I_COMMODITY = "200989"
          )
)
req$url
raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
jsonlite::validate(httr::content(req, as = "text"))


# US totals of imports by six-digit HS code in September of 2022
natl <- getCensus(
  name = "timeseries/intltrade/imports/hs",
  key = census_key,
  vars = c("I_COMMODITY",
           "I_COMMODITY_SDESC",
           "GEN_VAL_MO",
           "GEN_vAL_YR" # this doesn't work - why?
  ),
  time = "2022-09",
  COMM_LVL = "HS6",
  I_COMMODITY = "*"
)

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
raw_imports %>% saveRDS("data/imports_HS6_ports_2022-09.Rds")

raw_imports <- readRDS("data/imports_HS6_ports_2022-09.Rds")


ports_xwalk <- getCensus(
  name = "timeseries/intltrade/imports/porths",
  key = census_key,
  vars = c("PORT", "PORT_NAME"),
  time = "2022-09"
) %>% 
  mutate(st = str_extract(PORT_NAME, "(?<=, )\\w{2}$")) %>% 
  select(-time)

fl_imports <- raw_imports %>% 
  inner_join(
    ports_xwalk %>% filter(st == "FL"),
    by = "PORT"
  )

# what's the top commodity at FL ports?
fl_imports %>% 
  mutate(
    GEN_VAL_MO = as.numeric(GEN_VAL_MO),
    GEN_VAL_YR = as.numeric(GEN_VAL_YR),
  ) %>% 
  group_by(
    I_COMMODITY,
    I_COMMODITY_SDESC
  ) %>% 
  summarize(
    gen_val_mo = sum(GEN_VAL_MO),
    gen_val_yr = sum(GEN_VAL_YR),
  ) %>% 
  arrange(-gen_val_mo) %>% 
  head(10)

fl_summary <- fl_imports %>% 
  mutate(
    GEN_VAL_MO = as.numeric(GEN_VAL_MO),
    GEN_VAL_YR = as.numeric(GEN_VAL_YR),
  )  %>% 
  group_by(
    I_COMMODITY,
    I_COMMODITY_SDESC
  ) %>% 
  summarize(
    fl_gen_val_mo = sum(GEN_VAL_MO),
    fl_gen_val_yr = sum(GEN_VAL_YR),
  ) %>% 
  ungroup()

# shares at FL ports
fl_shares <- natl %>% 
  left_join(
    fl_summary
  ) %>% 
  mutate(
    fl_share_mo = fl_gen_val_mo / as.numeric(GEN_VAL_MO)
  )
