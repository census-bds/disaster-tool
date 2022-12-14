#===============================================================================#
# COMPUTE IMPORT SHARES
# Depends: imports data
# 2022-11-23
# Cecile Murray
#===============================================================================#

libs <- c(
  "tidyverse",
  "janitor"
)
lapply(libs, library, character.only = TRUE)


# input file paths
NATL_HS6_FILE <- "data/imports_HS6_natl_2022-09.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"
PORT_NAMES_FILE <- "tableau/imports_port_names.csv"
PORT_SHARES_PATH <- "tableau/import_port_share.csv"

# read in data
natl_imports <- readRDS(NATL_HS6_FILE)
raw_imports <- readRDS(PORTS_HS6_FILE)
ports_xwalk <- read_csv(PORT_NAMES_FILE)


# ANALYSIS   =============================#

fl_imports <- raw_imports %>% 
  inner_join(
    ports_xwalk %>% filter(STATEFP == "12"),
    by = "PORT"
  )

# what's the top commodity at FL ports?
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
fl_shares <- fl_imports %>% 
  left_join(
    natl_imports,
    suffix = c("_fl", ""),
    by = c(
      "I_COMMODITY",
      "I_COMMODITY_SDESC",
      "I_COMMODITY_1"
    )
  ) %>% 
mutate(
    fl_share_mo = as.numeric(GEN_VAL_MO_fl) / as.numeric(GEN_VAL_MO),
    fl_share_yr = as.numeric(GEN_VAL_YR_fl) / as.numeric(GEN_VAL_YR),
  )

fl_shares %>%
  select(I_COMMODITY_SDESC, contains("GEN_VAL_MO"), contains("fl_share")) %>% 
  View()

natl_imports %>% 
  mutate_at(
    vars(contains("GEN_VAL")),
    ~ as.numeric(.)
  ) 

# PRODUCE STATISTICS FOR TABLEAU  =============================#

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

port_shares %>% 
  filter(PORT != "-") %>%
  select(
    PORT,
    PORT_NAME,
    I_COMMODITY,
    I_COMMODITY_SDESC,
    contains("GEN_VAL"),
    contains("_share_")
  ) %>%
  View()

# look at one county
port_shares %>% 
  filter(PORT == "1801") %>% 
  select(
    PORT,
    PORT_NAME,
    I_COMMODITY,
    I_COMMODITY_SDESC,
    contains("GEN_VAL"),
    contains("_share_") 
  ) %>% 
  filter(GEN_VAL_YR_port > 500000) %>% 
  View()

# thinking about cut point for total value.. natl viz
natl_imports %>% 
  ggplot(
    aes(x = as.numeric(GEN_VAL_YR))
  ) +
  geom_freqpoly(binwidth = 500000)

quantile(as.numeric(natl_imports$GEN_VAL_YR), probs = c(0.05, 0.1))

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
  write_csv("tableau/imports_max_share_year.csv")
