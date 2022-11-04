#==========================================================#
# GET TOP PRODUCTS 
# Cecile Murray
# 2022-11-03
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "tidycensus",
          "sf",
          "tmap"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.get("CENSUS_API_KEY")

# load top location quotients by industry
max_lq <- readRDS("data/max_lq_QCEW_FL_2022Q1.Rds")

# load Florida geography
fl_geo <- readRDS("data/FL_county_geo.Rds")
fema_disaster_a <- readRDS("data/FEMA_affected_fips_A.Rds")

# load NAICS to NAPCS allocation factors
# naics2napcs <- readRDS("data/naics2napcs_natl_2017.Rds")
naics2napcs <- readRDS("data/natl_six_digit_EC1700NAPCSINDPRD.Rds") %>% 
  filter(NAPCS2017 != "0000000000")

# load full NAICS crosswalk since not all industries covered
naics_xwalk <- read_csv("https://www.bls.gov/cew/classifications/industry/industry-titles-csv.csv")

#PROBLEM!! need to fix that BLS is using 2022 NAICS, augh


#============================#

# join top LQ to allocation factors
product_rank <- max_lq %>% 
  select(-industry_title) %>% 
  left_join(
    naics2napcs,
    by = c("industry_code" = "NAICS2017")
  ) %>% 
  left_join(
    naics_xwalk,
    by = "industry_code"
  ) %>% 
  group_by(
    area_fips,
    industry_code,
    variable
  ) %>% 
  mutate(
    estab_pct_rank = min_rank(desc(ESTAB_PCT)),
    tvalln_rank = min_rank(desc(TVALLN))
  ) %>% 
  # now fix the agriculture-heavy counties
  mutate(
    estab_pct_rank = if_else(str_sub(industry_code, 1, 2) == "11", as.integer(1), estab_pct_rank),
    tvalln_rank = if_else(str_sub(industry_code, 1, 2) == "11", as.integer(1), tvalln_rank),
    industry_flag = if_else(is.na(NAPCS2017_TTL), 1, 0),
    NAPCS2017_TTL = if_else(industry_flag == 1, str_c(industry_title, " (I)"), NAPCS2017_TTL), # is this sketchy?
  ) %>% 
  ungroup()

# check that the flag did what it was supposed to
product_rank %>% filter(industry_flag == 1) %>% View()

#============================#
# MAPS
#============================#


# map top product by county
tmap_mode("view")
tmap_mode(max.categories = 81)

# map based on # estabs 
product_rank %>% 
  filter(
    variable == "lq_qtrly_estabs",
    estab_pct_rank == 1
  ) %>% 
  left_join(
    fl_geo,
    by = c("area_fips" = "GEOID")
  ) %>%  
  st_as_sf() %>% 
  tm_shape() +
  tm_borders() +
  tm_fill(
    col = "NAPCS2017_TTL",
    legend.show = FALSE,
    id = "NAME"
  )

# what about... estab LQ + TVALLN?
product_rank %>% 
  filter(
    variable == "lq_qtrly_estabs",
    tvalln_rank == 1
  ) %>% 
  left_join(
    fl_geo,
    by = c("area_fips" = "GEOID")
  ) %>%  
  st_as_sf() %>% 
  tm_shape() +
  tm_borders() +
  tm_fill(
    col = "NAPCS2017_TTL",
    legend.show = FALSE,
    id = "NAME"
  )

#============================#
# TOP PRODUCTS AFFECTED
#============================#

# how many times do each of these top products appear in the A area?  
product_rank %>% 
  filter(
    area_fips %in% fema_disaster_a$area_fips,
    variable == "lq_qtrly_estabs",
    tvalln_rank < 4
  ) %>% 
  count(NAPCS2017, NAPCS2017_TTL, sort = TRUE) %>% 
  View()
