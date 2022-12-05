#==========================================================#
# PREPARE INDUSTRY DATA FOR TABLEAU 
# Depends: QCEW data, NAICS list, county geo files
# Cecile Murray
# 2022-12-01

# 1. Compute the share of establishments in each NAICS in
#    each county. 
# 2. Merge that data to NAICS list
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

# input data 
natl_qcew <- readRDS("data/QCEW_US_2022Q1.Rds") 
county_qcew <- readRDS("data/QCEW_CTY_2022Q1.Rds")
naics_xwalk <- read_csv("data/2022_NAICS_titles.csv", col_types = cols(.default = "c"))

# output filepath
INDUSTRY_DATA_FOR_TABLEAU <- "tableau/US_county_estab_shares.csv"

#============================#

# for each six-digit NAICS, compute the share of national estabs in each county 
estab_data <- county_qcew %>% 
  filter(
    agglvl_code == "78", # six digit NAICS
    own_code == 5 # all private establishments, no govt
  ) %>%
  mutate(area_fips = str_pad(area_fips, 5, side = "left", pad = "0"))  %>%  
  select(
    one_of(c("area_fips", "industry_code", "qtrly_estabs"))
  ) %>% 
  left_join(
    natl_qcew %>% 
      filter(own_code == 5) %>% 
      select(industry_code, qtrly_estabs),
    by = c("industry_code"),
    suffix = c("", "_natl")
  ) %>% 
  mutate(
    estab_share = (qtrly_estabs / qtrly_estabs_natl) * 100
  ) %>% 
  left_join(
    naics_xwalk %>% select(industry_code, industry_title),
    by = "industry_code"
  )

# export to tableau
estab_data %>% write_csv(INDUSTRY_DATA_FOR_TABLEAU)