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
fl_geo <- get_acs(
  geography = "county",
  variables = c("B19001_001"),
  state = "12",
  geometry = TRUE
)

# load NAICS to NAPCS crosswalk 
naics2napcs <- readRDS("data/naics2napcs_natl_2017.Rds")

#============================#

# join top LQ to allocation factors
product_rank <- max_lq %>% 
  select(-industry_title) %>% 
  left_join(
    naics2napcs,
    by = c("industry_code" = "NAICS2017")
  ) %>% 
  group_by(
    area_fips,
    industry_code,
    variable
  ) %>% 
  mutate(
    napcs_share_rank = min_rank(desc(napcs_share))
  )

# map top product by county
tmap_options("view")

product_rank %>% 
  filter(napcs_share_rank == 1) %>% 
  left_join(
    fl_geo,
    by = c("area_fips" = "GEOID")
  ) %>% 
  st_as_sf() %>% 
  tm_shape() +
  tm_borders() +
  tm_fill(
    col = "NAPCS2017_description",
    legend.show = FALSE,
    id = "NAME"
  )

  