#==========================================================#
# DEFINE COUNTY LISTS 
# Cecile Murray
# 2022-11-04
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

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

# get geography from tidycensus
cty_geo <- get_acs(
  geography = "county",
  variables = c("B19001_001"),
  geometry = TRUE
) %>% 
  select(
    -variable,
    -estimate,
    -moe
  )

# for use in Tableau
cty_geo %>% sf::st_write("tableau/US_county.shp")


#============================#

# counties where individuals can apply for assistance (highest level?)
fema_disaster_a_list <- tibble(
  "county" = c(
  "Brevard",
  "Charlotte",
  "Collier",
  "DeSoto",
  "Flagler",
  "Glades",
  "Hardee",
  "Hendry",
  "Highlands",
  "Hillsborough",
  "Lake",
  "Lee",
  "Manatee",
  "Monroe",
  "Okeechobee",
  "Orange",
  "Osceola",
  "Palm Beach",
  "Pasco",
  "Pinellas",
  "Polk",
  "Putnam",
  "Sarasota",
  "Seminole",
  "St. Johns",
  "Volusia"
)
)

fema_disaster_a <- map_dfr(
  fema_disaster_a_list,
  ~ str_c(., " County")
  ) %>% 
  left_join(
    fips_codes %>% 
      filter(state == "FL") %>% 
      mutate(area_fips = str_c(state_code, county_code)),
    by = "county"
  )

fema_disaster_a %>% saveRDS("data/FEMA_affected_fips_A.Rds")  

#============================#
# MAKE .shp FILE FOR TABLEAU
#============================#

cty_geo %>% 
  mutate(disaster_a = if_else(GEOID %in% fema_disaster_a$area_fips, 1, 0)) %>% 
  sf::st_write("data/US_county_with_disaster.shp")
