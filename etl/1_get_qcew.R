#==========================================================#
# GET QCEW LQ DATA 
# Depends: BLS API key + internet access
# Cecile Murray
# 2022-10-21
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "blscrapeR",
          "tidycensus"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

bls_key <- Sys.getenv("BLS_KEY")

#============================#

# construct list of all county FIPS for BLS
county_fips <- read_csv("https://www.bls.gov/cew/classifications/areas/area-titles-csv.csv") %>% 
  mutate(area_fips = str_pad(area_fips, width = 5, side = "left", pad = "0")) %>% 
  filter(
    !str_detect(area_fips, "^US|^C[1-5]"),
    !str_detect(area_fips, "000$|99[6-9]$"),
    !str_detect(area_fips, "^CS")
  ) 

# method to call QCEW API for a given FIPS
# BLS is serving csv files for each geography in a "slice" so we have to do
# a repeated call to qcew_api() method
# see https://data.bls.gov/cew/doc/access/csv_data_slices.htm
get_qcew <- function(area_fips) {
  out <- tryCatch(
    {
      qcew_api(
        year = 2022,
        quarter = 1,
        slice = "area",
        sliceCode = area_fips
      ) %>% 
        mutate(area_fips = as.character(area_fips))
    },
    error=function(cond) {
      message("Error in API call for FIPS:", area_fips)
      message(cond)
      # Choose a return value in case of error
      return(data.frame())
    },
    warning=function(cond) {
      message(paste("API call caused a warning:", area_fips))
      message("Here's the warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(data.frame())
    }
  )
}

# make API call for the whole US
natl_qcew <- get_qcew("US000")

# make API call for all of FL
fl_qcew <- get_qcew("12000")

# make API calls for all counties and bind in long DF
county_qcew <- map_dfr(
  county_fips$area_fips, 
  ~ get_qcew(.) 
) %>%
  mutate(
    area_fips = str_pad(area_fips, width = 5, side = "left", pad = "0")
  )  

# save it as .Rds for convenience
natl_qcew %>% saveRDS("data/QCEW_US_2022Q1.Rds")
fl_qcew %>% saveRDS("data/QCEW_FLST_2022Q1.Rds")
county_qcew %>% saveRDS("data/QCEW_CTY_2022Q1.Rds")
