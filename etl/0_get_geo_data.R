#==========================================================#
# GET GEOGRAPHIC DATA AND SET AFFECTED LIST
# Depends: Census API key, internet, affected county csv
# Cecile Murray
# 2022-11-04
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "tigris",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

# needs to contain a list of disaster county names in a column named "county"
# we expect a bare county name, without the " County" at the end
AFFECTED_COUNTY_CSV <- "affected_counties.csv" 

# output shapefile
COUNTY_DISASTER_SHAPEFILE <- "tableau/US_county_with_disaster.shp"

#============================#

# get geography from tidycensus
fl_geo <- get_acs(
  geography = "county",
  variables = c("B19001_001"),
  state = "12",
  geometry = TRUE
) %>% 
  select(
    -variable,
    -estimate,
    -moe
  )

# for use within R
fl_geo %>% saveRDS("data/FL_county_geo.Rds")

# for use in Tableau
fl_geo %>% sf::st_write("data/FL_county.shp")

# get geography from tigris
cty_geo <- counties(cb = TRUE, year = "2021")

#============================#

affected_county_list <- read_csv(AFFECTED_COUNTY_CSV)

# counties where individuals can apply for assistance
fema_disaster_a <- affected_county_list %>%
  mutate(
    county = str_c(county, " County")
  ) %>% 
  left_join(
    fips_codes %>% 
      mutate(area_fips = str_c(state_code, county_code)),
    by = c("county", "state")
  )

# 1. make sure we have one row for each provided county
# 2. make sure that every county now has a FIPS 
assertthat::are_equal(nrow(fema_disaster_a), nrow(affected_county_list))
assertthat::assert_that(length(which(is.na(fema_disaster_a$area_fips))) == 0)

fema_disaster_a %>% saveRDS("data/FEMA_affected_fips_A.Rds")  

#============================#
# MAKE .shp FILE FOR TABLEAU
#============================#

cty_geo %>% 
  mutate(disaster_a = if_else(GEOID %in% fema_disaster_a$area_fips, 1, 0)) %>% 
  select(-ALAND, -AWATER) %>% 
  sf::st_write(COUNTY_DISASTER_SHAPEFILE, append=FALSE)
