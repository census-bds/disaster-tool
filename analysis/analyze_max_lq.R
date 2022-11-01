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
          "tidycensus",
          "tmap"
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

# check distribution of LQs
max_lq %>% 
  ggplot(
    aes(
      x = max_value
    )
  ) +
  geom_histogram() +
  facet_grid(rows = vars(variable))

# what is the minimum value for each measure?
max_lq %>% 
  group_by(variable) %>% 
  summarize(min_lq = min(max_value)) 

# what are the percentile cuts?
max_lq %>% 
  group_by(variable) %>% 
  summarize(
    lq_min = min(max_value),
    lq_25th = quantile(max_value, 0.25),
    lq_50th = quantile(max_value, 0.50),
    lq_75th = quantile(max_value, 0.75),
    lq_max = quantile(max_value, 1)
  ) 

#============================#

# static map some LQ data on estabs
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
tmap_mode("view")

max_lq %>%
  filter(variable == "lq_qtrly_estabs") %>% 
  left_join(
    fl_geo %>% select(GEOID, geometry),
    by = c("area_fips" = "GEOID")
  ) %>% 
  st_as_sf() %>% 
  tm_shape() +
    tm_borders() +
    tm_fill(
      col = "industry_title",
      legend.show = FALSE)
