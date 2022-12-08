#==========================================================#
# TEST VALUES 
# Depends: all of the previous ETL needs to run
# Cecile Murray
# 2022-12-06
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "sf",
          "assertthat"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

# inputs here are all of the files created in previous steps, which
# will be loaded into Tableau
IMPORT_PORT_SHARE <- "tableau/import_port_share.csv"
NAICS2NAPCS <- "tableau/import_port_share.csv"
US_COUNTY_ESTAB_SHARE <- "tableau/US_county_estab_shares.csv"
COUNTY_SHP <- "tableau/US_county_with_disaster.shp"

#============================#
# READ IN AND PREP

# read in inputs
imports <- read_csv(IMPORT_PORT_SHARE)
naics2napcs <- read_csv(NAICS2NAPCS)
estab <- read_csv(US_COUNTY_ESTAB_SHARE)
cty <- read_sf(COUNTY_SHP)

# join estab to geos
estab_geo <- estab %>% 
  left_join(
    cty, 
    by = c("area_fips" = "GEOID")
  )

#============================#
# GENERAL VALUE TESTS

# no negative estab shares
# no estab shares > 100
# no null estab shares
assert_that(sum(estab$estab_share < 0) == 0)
assert_that(sum(estab$estab_share > 100) == 0)
assert_that(length(which(is.na(estab$estab_share))) == 0)

# no negative import shares
# no import shares > 100
# no null import shares
assert_that(sum(imports$port_share_yr < 0) == 0)
assert_that(sum(imports$port_share_yr > 100) == 0)
assert_that(length(which(is.na(imports$port_share_yr))) == 0)

#============================#
# COUNTY COVERAGE
# is there a value for every county where there's supposed to be?

# these are FIPS for counties that aren't present in the BLS QCEW list, 
# mostly territories
missing_fips <- c(
  "15005", # Kalawao County HI: BLS QCEW contains in in Maui County 15009
  "60010", # Eastern District, AS
  "60020", # Manu'a District, AS
  "60030", # Rose Atoll, AS
  "60040", # Swain's Island, AS
  "60050", # Western District, AS
  "66010", # Guam
  "69085", # Northern Islands Municipality, Northern Mariana Islands
  "69100", # Rota Municipality, Northern Mariana Islands
  "69110", # Saipain Municipality, Northern Mariana Islands
  "69120" # Tinian Municipality, Northern Mariana Islands
)

# this says every county we get from BLS is covered in the shapefile
assert_that(length(setdiff(estab$area_fips, cty$GEOID)) == 0)

# this says the only counties in the shapefile where we don't have data from
# BLS are the ones listed above
assert_that(setequal(setdiff(cty$GEOID, estab$area_fips), missing_fips))

#============================#
# TEST ESTAB NUMBERS

# there's rounding in this section because of floating point error
# and because Tableau rounds and that's what I'm checking against


# compute topline statistic about orange groves
affected_orange_groves_estab_share <- estab_geo %>% 
  filter(
    disaster_a == 1,
    industry_code == "111310"
  ) %>% 
  select(estab_share) %>% 
  sum()

assert_that(round(affected_orange_groves_estab_share[1], 2) == 46.48)  

# compute stat about % of strawberry farming estabs in Hillsborough County FL
hillsborough_strawberry_estab_share <- estab %>% 
  filter(
    industry_code == "111333",
    area_fips == "12057"
  ) %>% 
  select(estab_share) %>% 
  as.double()

assert_that(round(hillsborough_strawberry_estab_share, 2) == 12.58)
                      
# compute stat about product in space vehicle propulsion NAICS
space_vehicle_engine_part_share <- naics2napcs %>% 
  filter(
    NAICS2017 == "336415",
    NAPCS2017 == "2012525000"
  ) %>% 
  select(ESTAB_PCT) %>% 
  as.double()

assert_that(space_vehicle_engine_part_share == 56.7)

#============================#
# TEST IMPORT NUMBERS

# compute stat about total YTD value of imports in Tampa
ytd_import_value_in_Tampa <-  imports %>% 
  filter(
    CITY == "TAMPA",
    STATE == "FL"
  ) %>% 
  select(GEN_VAL_YR_port) %>% 
  sum()

assert_that(ytd_import_value_in_Tampa == 3041763483)
