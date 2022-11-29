#==========================================================#
# CONVERT NAICS VINTAGES
# Depends: internet access, 2017-2022 NAICS concordance xlsx
# Cecile Murray
# 2022-11-07
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "readxl"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

#============================#
# DATA LOADING
#============================#

# input
NAICS_CONCORDANCE_FILE <- "data/2017_to_2022_NAICS.xlsx"
NATL_QCEW <- "data/QCEW_US_2022Q1.Rds"

# output
NAICS_TITLE_FILE <- "data/2022_NAICS_titles.csv"

# load 2017 to 2022 NAICS concordance file
naics_concordance <- read_excel(
  NAICS_CONCORDANCE_FILE,
  skip=2,
  col_types = "text"
) %>% 
  clean_names() %>% 
  select(contains("2017"), contains("2022")) %>% 
  rename("x2017_naics_title" = "x2017_naics_title_and_specific_piece_of_the_2017_industry_that_is_contained_in_the_2022_industry")

# grab BLS list
bls_naics <- read_csv("https://www.bls.gov/cew/classifications/industry/industry-titles-csv.csv")

# load actual QCEW data that we need to label
natl_qcew <- readRDS(NATL_QCEW) 

#============================#
# WHICH NAICS LIST IS BEST?
#============================#

# first, clean up NAICS label and make variable flag indicating which vintage
bls_naics6 <- bls_naics %>% 
  filter(str_length(industry_code) == 6) %>% 
  rename("industry_title_full" = "industry_title") %>% 
  mutate(
    naics_year = if_else(
      str_detect(industry_title_full, "NAICS\\d{2}"),
      str_extract(industry_title_full, "NAICS\\d{2}"), 
      "22"
    ),
    industry_title = str_remove(industry_title_full, "NAICS(\\d{2})? \\d{6} ")
  ) 

# now, investigate why some QCEW NAICS didn't join to a label from the 
# Census NAICS 2022 list

# get distinct NAICS from QCEW data
target_naics <- natl_qcew %>% 
  filter(str_length(industry_code) == 6) %>% 
  distinct(industry_code)

# this tells me it's 999999 (unknown) and a lot of subsector 238 
# looks like a lot of residential vs. non-residential... odd
setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code)

# are these ones present in the BLS list? - yes!
setdiff(
  setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code),
  bls_naics6$industry_code
)


#============================#
# COMBINE SOURCES
#============================#

# make data frame of just the missing 
naics_to_add <- bls_naics6 %>% 
  filter(
    industry_code %in% setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code)
  )

naics_df <- naics_concordance %>% 
  select(contains("x2022")) %>% 
  distinct() %>% 
  rename(
    "industry_code" = "x2022_naics_code",
    "industry_title" = "x2022_naics_title"
  ) %>% 
  mutate(
    industry_title_full = "",
    vintage = "22"
  ) %>% 
  bind_rows(naics_to_add)


#============================#
# EXPORT
#============================#

naics_df %>% write_csv(NAICS_TITLE_FILE)
