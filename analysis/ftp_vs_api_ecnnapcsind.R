ftp <- read_delim(NATL_ECON_CENSUS_FILE)

natl_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "us:*",
  vintage = 2017,
  key = census_key
) %>% 
  mutate(
    NAICS2017 = as.character(NAICS2017),
    NAPCS2017 = as.character(NAICS2017)
  )

st_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "state:*",
  vintage = 2017,
  key = census_key
 ) 

length(unique(st_econ_census$NAICS2017)) #472


ftp %>% 
  filter(`#GEOTYPE` == "02") %>% 
  distinct(NAICS2017) %>% 
  nrow() # also 472

ftp %>% filter(NAPCS2017 == "0000000000") %>% glimpse()

# perfect overlap in national NAICS? yes
setdiff(naics2napcs$NAICS2017, natl_econ_census$NAICS2017)
setdiff(natl_econ_census$NAICS2017, naics2napcs$NAICS2017)

# also perfect overlap here
setdiff(filter(ftp, `#GEOTYPE`=="02")$NAICS2017, st_econ_census$NAICS2017)
setdiff(st_econ_census$NAICS2017, filter(ftp, `#GEOTYPE`=="02")$NAICS2017)
