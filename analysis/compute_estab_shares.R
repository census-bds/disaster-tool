#==========================================================#
# COMPUTE ESTAB SHARES 
# Cecile Murray
# 2022-11-07
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "tidycensus",
          "tmap"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))


natl_qcew <- readRDS("data/QCEW_US_2022Q1.Rds") 
fl_qcew <- readRDS("data/QCEW_FLST_2022Q1.Rds")
county_qcew <- readRDS("data/QCEW_FL_2022Q1.Rds")

naics2napcs <- readRDS("data/natl_six_digit_EC1700NAPCSINDPRD.Rds") %>% 
  filter(NAPCS2017 != "0000000000") 

naics_xwalk <- readRDS("data/naics_2017_to_2022_concordance.Rds")

fl_geo <- readRDS("data/FL_county_geo.Rds")
fema_disaster_a <- readRDS("data/FEMA_affected_fips_A.Rds")

vars_to_keep <- c("area_fips", "industry_code", "qtrly_estabs")

# for each six-digit NAICS, compute the share of national estabs in each county 
estab_data <- county_qcew %>% 
  filter(agglvl_code == "78", own_code == 5) %>%
  mutate(area_fips = str_pad(area_fips, 5, side = "left", pad = "0"))  %>%  # move this
  select(one_of(vars_to_keep)) %>% 
  left_join(
    natl_qcew %>% 
      filter(own_code == 5) %>% 
      select(industry_code, qtrly_estabs),
    by = c("industry_code"),
    suffix = c("", "_natl")
  ) %>% 
  mutate(
    estab_share = qtrly_estabs / qtrly_estabs_natl
  ) %>% 
  left_join(
    naics_xwalk %>% distinct(x2022_naics_code, x2022_naics_title),
    by = c("industry_code" = "x2022_naics_code")
  )

# then let's say you wanted to combine for area A
area_a_estab_share <- county_qcew %>% 
  filter(
    agglvl_code == "78",
    own_code == 5,
  ) %>%
  mutate(area_fips = str_pad(area_fips, 5, side = "left", pad = "0"))  %>%  # move this
  inner_join(
    fema_disaster_a %>% select(area_fips, county),
    by = "area_fips"
  ) %>% 
  select(one_of(vars_to_keep)) %>% 
  left_join(
    natl_qcew %>% 
      filter(own_code == 5) %>% 
      select(industry_code, qtrly_estabs),
    by = c("industry_code"),
    suffix = c("", "_natl")
  ) %>% 
  group_by(industry_code) %>% 
  summarize(
    qtrly_estabs = sum(qtrly_estabs, na.rm=TRUE),
    qtrly_estabs_natl = first(qtrly_estabs_natl)
  ) %>% 
  mutate(
    estab_share = qtrly_estabs / qtrly_estabs_natl
  ) %>% 
  left_join(
    naics_xwalk %>% distinct(x2022_naics_code, x2022_naics_title),
    by = c("industry_code" = "x2022_naics_code")
  )

# and what is the benchmark for FL share of estabs?
fl_estab_total <- fl_qcew %>% 
  filter(
    agglvl_code == 58,
    own_code == 5
  ) %>% 
  summarize(qtrly_estabs = sum(qtrly_estabs))

natl_estab_total <- natl_qcew %>% 
  filter(
    agglvl_code == 18,
    own_code == 5
  ) %>% 
  summarize(qtrly_estabs = sum(qtrly_estabs))

fl_estab_total$qtrly_estabs / natl_estab_total$qtrly_estabs # 7.6%

#============================#
# what if I then tried to link to products (ranking)?

# rank industries in disaster zone by % of national estabs, then find top 3 products 
area_a_estab_share %>% 
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
  group_by(
    industry_code
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
  ungroup() %>% 
  filter(tvalln_rank < 4) %>% 
  arrange(-estab_share, tvalln_rank) %>% 
  View()

# and a map
estab_data %>% 
  group_by(area_fips) %>% 
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
  group_by(
    area_fips,
    industry_code
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
  ungroup() %>% 
  filter(tvalln_rank == 1) %>% 
  inner_join(
    fl_geo,
    by = c("area_fips" = "GEOID")
  )
  