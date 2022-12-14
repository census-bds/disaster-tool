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
          "readxl"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))


# input paths
NAICS_CONCORDANCE_FILE <- "data/2017_to_2022_NAICS.xlsx"
NATL_QCEW <- "data/QCEW_US_2022Q1.Rds"

# link to download NAICS concordance
NAICS_URL <- "https://www.census.gov/naics/concordances/2022_to_2017_NAICS.xlsx"

# output paths
NAICS_TITLE_FILE <- "data/2022_NAICS_titles.csv"

#============================#
# DOWNLOAD NAICS CONCORDANCE
#============================#

return_code <- download.file(
  url = NAICS_URL, 
  destfile = NAICS_CONCORDANCE_FILE, 
  method = "curl",
  mode = "wb"
) 

# if we were successful, unzip
if (return_code == 0) {
  print("NAICS concordance download successful.")
  # otherwise throw an error
} else {
  stop("NAICS concordance download was not successful.")
}

#============================#
# DATA LOADING
#============================#

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

# THE REST OF THIS SECTION DOCUMENTS THE NAICS LIST DECISION
# investigate why some QCEW NAICS don't fully join to a label from the 
# Census NAICS 2022 list
# natl_qcew <- readRDS("data/QCEW_US_2022Q1.Rds")

# # get distinct NAICS from QCEW data
target_naics <- natl_qcew %>%
  filter(str_length(industry_code) == 6) %>%
  distinct(industry_code)
# 
# # this tells me it's 999999 (unknown) and a lot of subsector 238 
# # looks like a lot of residential vs. non-residential... odd, but okay
setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code)
# 
# # are these ones present in the BLS list? - yes
setdiff(
  setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code),
  bls_naics6$industry_code
)

#============================#
# COMBINE SOURCES
#============================#

# make data frame of just the NAICS that don't join to Census NAICS list 
naics_to_add <- bls_naics6 %>% 
  filter(
    industry_code %in% setdiff(target_naics$industry_code, naics_concordance$x2022_naics_code)
  )

# add these missing NAICS to the Census list
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
