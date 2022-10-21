#==========================================================#
# EXPLORE ECON CENSUS DATA 
# Cecile Murray
# 2022-10-20
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

# get saved API key from .Renviron
api_key <- Sys.getenv("CENSUS_API_KEY")

#============================#

# test API call for ASM
asm_state <- getCensus(
  name = "timeseries/asm/area2017",
  vars = c("STATE", "NAICS2017", "RCPTOT"),
  region = "us:*",
  time = 2020,
  key = api_key
  )

# test API call for CBP
cbp_county <- getCensus(
  name = "cbp",
  vars = c("SECTOR", "NAICS2017", "EMP"),
  region = "county:*",
  vintage = 2020,
  key = api_key
)

econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "state:*",
  vintage = 2017,
  key = api_key
)

FL_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAPCS2017", "TVALLN"),
  region = "county:*",
  vintage = 2017,
  key = api_key
)
