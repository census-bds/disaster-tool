#==========================================================#
# GET QCEW LQ DATA 
# Cecile Murray
# 2022-10-21
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "blscrapeR",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

bls_key <- Sys.getenv("BLS_KEY")
census_key <- Sys.getenv("CENSUS_API_KEY")

#============================#

# construct list of all FL county FIPS
county_fips <- read_csv("https://www.bls.gov/cew/classifications/areas/area-titles-csv.csv") %>% 
  mutate(area_fips = str_pad(area_fips, width = 5, side = "left", pad = "0")) %>% 
  filter(
    !str_detect(area_fips, "^US|^C[1-5]"),
    !str_detect(area_fips, "000$|99[6-9]$")
  ) %>% 
  filter(
    str_sub(area_fips, 1, 2)  == "12",
    area_fips != "12025"
  ) # for now just get FL and drop this county because ???

# make API call for the whole US
natl_qcew <- qcew_api(
  year = 2022,
  quarter = 1,
  slice = "area",
  sliceCode = "US000"
)

# make API call for all of FL
fl_qcew <- qcew_api(
  year = 2022,
  quarter = 1,
  slice = "area",
  sliceCode = "12000"
)


get_qcew <- function(area_fips) {
  out <- tryCatch(
    {
      qcew_api(
        year = 2022,
        quarter = 1,
        slice = "area",
        sliceCode = area_fips
      )
    },
    error=function(cond) {
      message("Error in API call for FIPS:", area_fips)
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("API call caused a warning:", area_fips))
      message("Here's the warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NA)
    }
  )
}


# make API calls for all FL counties and bind in long DF
county_qcew <- map_dfr(
  county_fips$area_fips,
  ~ qcew_api(
    year = 2022,
    quarter = 1,
    slice = "area",
    sliceCode = .
  )
) %>%
  mutate(
    area_fips = str_pad(area_fips, width = 5, side = "left", pad = "0")
  )  

# fix problem NAICS
  
# save it as .Rds for convenience
natl_qcew %>% saveRDS("data/QCEW_US_2022Q1.Rds")
fl_qcew %>% saveRDS("data/QCEW_FLST_2022Q1.Rds")
county_qcew %>% saveRDS("data/QCEW_FL_2022Q1.Rds")
