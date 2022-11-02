#==========================================================#
# GET ECON CENSUS DATA FOR NAICS TO NAPCS XWALK
# Cecile Murray
# 2022-11-01
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "readxl",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

options(scipen = 999) # to eliminate scientific notation in hierarchal codes

#============================#
# GET DATA
#============================#


naics_xwalk <- read_csv("https://www.bls.gov/cew/classifications/industry/industry-titles-csv.csv")

napcs_xwalk <- readxl::read_xlsx(
  "data/2017_to_2022_NAPCS_Concordance_Final_08242022.xlsx",
  col_types = "text",
  sheet = 2
) %>% 
  clean_names()

st_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "state:*",
  vintage = 2017,
  key = census_key
)

natl_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "us:*",
  vintage = 2017,
  key = census_key
)

#============================#

compute_naics2napcs <- function(df) {
  df %>% 
    mutate(
      NAICS2017 = str_pad(NAICS2017, 6, side = "left", pad = "0"),
      NAPCS2017 = str_c(NAPCS2017) 
    ) %>% 
    filter(str_starts(NAICS2017, "[1-9]")) %>%
    group_by(
      GEO_ID,
      NAICS2017
    ) %>% 
    mutate(
      TVALLN = as.numeric(TVALLN),
      naics_sum = sum(TVALLN, na.rm=TRUE),
      napcs_ct = n(),
      napcs_share = TVALLN / naics_sum
    ) %>% 
    ungroup() %>% 
    left_join(
      naics_xwalk,
      by = c("NAICS2017" = "industry_code")
    ) %>% 
    left_join(
      napcs_xwalk %>% 
        select(
          x2017_napcs_based_collection_code,
          x2017_napcs_based_description
        ),
      by = c("NAPCS2017" = "x2017_napcs_based_collection_code")
    ) %>% 
    rename("NAPCS2017_description" = "x2017_napcs_based_description") %>% 
    select(
      GEO_ID,
      NAICS2017,
      industry_title,
      NAPCS2017,
      NAPCS2017_description,
      everything()
    )
}

natl_naics2napcs <- natl_econ_census %>% compute_naics2napcs()

# TODO: look at state-level factors and see variation


