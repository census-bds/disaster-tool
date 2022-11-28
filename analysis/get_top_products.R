#==========================================================#
# GET TOP PRODUCTS 
# Cecile Murray
# 2022-11-28
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

census_key <- Sys.getenv("CENSUS_API_KEY")

# load top location quotients by industry
max_lq <- readRDS("data/max_lq_QCEW_FL_2022Q1.Rds")

# load Florida geography
fl_geo <- readRDS("data/FL_county_geo.Rds")
fema_disaster_a <- readRDS("data/FEMA_affected_fips_A.Rds")

# load NAICS to NAPCS allocation factors
# naics2napcs <- readRDS("data/naics2napcs_natl_2017.Rds")
naics2napcs <- readRDS("data/natl_six_digit_EC1700NAPCSINDPRD.Rds") %>% 
  filter(NAPCS2017 != "0000000000") 

# load full 2017 and 2022 NAICS crosswalk since there's a difference in vintage
# and not all industries are covered in EC
naics_xwalk <- readRDS("data/naics_2017_to_2022_concordance.Rds")

#============================#

# join top LQ to allocation factors
product_rank <- max_lq %>% 
  select(
    -industry_title,
    -own_code,
    -agglvl_code,
    -contains("disclosure")
  ) %>% 
  left_join(
    naics2napcs %>% 
      select(
        NAICS2017,
        NAICS2017_TTL,
        NAPCS2017,
        NAPCS2017_TTL,
        TVALLN,
        TVALLN_F,
        ESTAB_PCT,
        ESTAB_PCT_F
      ),
    by = c("industry_code" = "NAICS2017")
  ) %>% 
  left_join(
    naics_xwalk %>% distinct(x2022_naics_code, x2022_naics_title),
    by = c("industry_code" = "x2022_naics_code")
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
    industry_flag = if_else(is.na(NAPCS2017_TTL), 1, 0), # flag ones we leave as industry bc not in econ census
    NAPCS2017_TTL = case_when(
      industry_flag == 1 & industry_code %in% c("238161", "238162", "238321", "238912") ~ "Building Finishing Contractors (I)*",
      industry_flag == 1 ~ str_c(x2022_naics_title, " (I)"), # add an (I) 
      # ^ fix random missing NAICS???
    TRUE ~ NAPCS2017_TTL) 
) %>% 
  ungroup()

# check that the flag did what it was supposed to: moved 2022 NAICS title to NAPCS2017 slot
product_rank %>% filter(industry_flag == 1) %>% glimpse()

# check for concordance issues with 2017/2022 NAICS codes
product_rank %>% 
  filter(is.na(NAPCS2017_TTL)) %>% # 7 of them, with 4 distinct NAICS 
  left_join(
    naics_xwalk %>% distinct(x2017_naics_code, x2017_naics_title),
    by = c("industry_code" = "x2017_naics_code")
  ) %>% 
  distinct(industry_code)
# they don't join??


#============================#
# MAPS
#============================#


# map top product by county
tmap_mode("view")
tmap_mode(max.categories = 81)

# map based on just disaster area
product_rank %>% 
  filter(
    variable == "lq_qtrly_estabs",
    tvalln_rank == 1
  ) %>% 
  inner_join(
    fl_geo %>% 
      inner_join(
        fema_disaster_a,
        by = c("GEOID"= "area_fips")
      ),
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

# what about the whole state?
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

#============================#
# HACKY NUMBER OF ESTABS?
#============================#

