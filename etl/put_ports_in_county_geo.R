#===============================================================================#
# PERFORM SPATIAL JOIN OF PORTS TO COUNTIES
# 2022-11-23
# Cecile Murray
#===============================================================================#

libs <- c(
  "here",
  "tidyverse",
  "janitor",
  "tigris",
  "sf"
)
lapply(libs, library, character.only = TRUE)

PORT_XWALK_FILE <- "data/major_port_county_xwalk.Rds"

# county shp from TIGER-line
cty <- counties()

# read shapefile from BTS website
ports_shp <- st_read("data/Principal_Port.shp")

# CHECK CRS =============================#

if (st_crs(cty) == st_crs(ports_shp)) {
  print("Coordinate systems match, nothing to do")
} else {
  
  print("Coordinate systems don't match; reprojecting")
  # reproject the ports one into the census one
  # this magic number is the CRS ID for WGS 1983, can be found in the output
  # from st_crs(cty)
  ports_shp <- ports_shp %>% st_transform(4269)
  
}
  
# check coordinate reference system again
assertthat::assert_that(st_crs(cty) == st_crs(ports_shp))

# PERFORM JOIN  =============================#

port_in_cty <- st_join(ports_shp, cty)

# get a simple tibble without spatial features, all string types
port_cty_df <- port_in_cty %>% 
  select(
    PORT, 
    PORT_NAME,
    RANK,
    GEOID,
    STATEFP,
    NAMELSAD
  ) %>% 
  st_drop_geometry() %>% 
  mutate_all(~ as.character(.))

port_cty_df %>% saveRDS(PORT_XWALK_FILE)
