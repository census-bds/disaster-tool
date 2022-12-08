#==========================================================#
# COMPUTE IMPORT SHARES BY PORT
# Depends: import data 
# Cecile Murray
# 2022-12-08
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr"
          )
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

# inputs
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"
PORT_NAMES_FILE <- "tableau/imports_port_totals.csv"

# output for tableau
PORT_SHARES_PATH <- "tableau/import_port_share.csv"


# if needed, option to read data in instead of pulling from API if this
# is a re-run
natl <- readRDS(NATL_HS6_FILE)
raw_imports <- readRDS(PORTS_HS6_FILE)
ports <- read_csv(PORT_NAMES_FILE)


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
      GEN_VAL_MO_port == 0 & GEN_VAL_MO == 0,
      0,
      GEN_VAL_MO_port / GEN_VAL_MO * 100
    ),
    port_share_yr = if_else( 
      GEN_VAL_YR_port == 0 & GEN_VAL_YR == 0,
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
