#==========================================================#
# ANALYZE MAX LQ DATA
# Cecile Murray
# 2022-10-31
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

max_lq <- readRDS("data/max_lq_QCEW_FL_2022Q1.Rds")

# load Florida geography
fl_geo <- get_acs(
  geography = "county",
  variables = c("B19001_001"),
  state = "12",
  geometry = TRUE
)

# load NAICS crosswalk 
naics_xwalk <- read_csv("https://www.bls.gov/cew/classifications/industry/industry-titles-csv.csv")

#============================#

# map some LQ data on estabs
max_lq %>%
  filter(variable == "lq_qtrly_estabs") %>% 
  left_join(
    fl_geo %>% select(GEOID, geometry),
    by = c("area_fips" = "GEOID")
  ) %>% 
  ggplot(
    aes(
      fill = industry_title,
      alpha = log(max_value),
      geometry = geometry
    )
  ) +
  geom_sf() +
  theme(legend.position = "bottom")

# try this in tmap so it is interactive?
library(tmap)
