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

natl_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "us:*",
  vintage = 2017,
  key = census_key
) %>% 
  mutate(
    NAICS2017 = str_pad(NAICS2017, 6, side = "left", pad = "0"),
    NAPCS2017 = as.character(NAICS2017)
  )

st_econ_census <- getCensus(
  name = "ecnnapcsind",
  vars = c("GEO_ID", "NAICS2017", "NAPCS2017", "TVALLN"),
  region = "state:*",
  vintage = 2017,
  key = census_key
) %>% 
  mutate(
    NAICS2017 = str_pad(NAICS2017, 6, side = "left", pad = "0"),
    # NAPCS2017 = str_pad(NAICS2017, 10, side = "left", pad = "0")
  )


# save for convenience
natl_econ_census %>% saveRDS("data/econ_census_napcsind_natl_2017.Rds")
st_econ_census %>% saveRDS("data/econ_census_napcsind_state_2017.Rds")

#============================#
# MAKE ALLOCATION FACTORS
#============================#

# compute share of TVALLN in a given NAPCS for a given six-digit NAICS
compute_naics2napcs <- function(df) {
  df %>% 
    filter(str_starts(NAICS2017, "[1-9]")) %>% # get six-digit NAICS
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
st_naics2napcs <- st_econ_census %>% compute_naics2napcs()

# save NAICS 2 NAPCS xwalk
natl_naics2napcs %>% saveRDS("data/naics2napcs_natl_2017.Rds")

#============================#
# DIAGNOSTICS
#============================#

# compute unique codes
count_unique_codes <- function(df, code_var, code_len) {
  df %>% 
    filter(str_length(!!sym(code_var)) == code_len) %>% 
    distinct(!!sym(code_var)) %>% 
    nrow()
}

# identify missing codes by higher level code
identify_missing_codes <- function(df, xwalk, code_var, code_len) {
  xwalk %>% 
    anti_join(
      df,
      by = code_var
    ) %>% 
    mutate(major_code = str_sub(!!sym(code_var), 1, code_len)) %>% 
    count(major_code) 
}

# NAICS
naics_xwalk %>% count_unique_codes("industry_code", 6) # 1301
natl_econ_census %>% count_unique_codes("NAICS2017", 6) # 946
st_econ_census %>% count_unique_codes("NAICS2017", 6) # 201

# NAICS missing
natl_econ_census %>%
  dplyr::rename("industry_code" = "NAICS2017") %>% 
  identify_missing_codes(naics_xwalk, "industry_code", 2)

# NAPCS
napcs_xwalk %>% count_unique_codes("x2017_napcs_based_collection_code", 10) # 8237
natl_econ_census %>% count_unique_codes("NAPCS2017", 10) # 1971
st_econ_census %>% count_unique_codes("NAPCS2017", 10) # 472
