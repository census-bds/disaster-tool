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

BLS_NAICS6_FILE <- "data/bls_naics6_titles.csv"
NAICS_CONCORDANCE_FILE <- "data/2017_to_2022_NAICS.xlsx"

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

#============================#
# ANALYSIS, TO CHECK
#============================#

# # how many six-digit NAICS were condensed between 2017 and 2022? 
# condensed_naics <- naics_concordance %>% 
#   count(x2022_naics_code) %>% 
#   filter(n > 1) # 79
# 
# # what sectors?
# condensed_naics %>% 
#   mutate(sector = str_sub(x2022_naics_code, 1, 2)) %>% 
#   count(sector)
# # mostly retail

# qcew <- readRDS("data/QCEW_FL_2022Q1.Rds")

# qcew_converted <- qcew %>% 
# left_join(
#   naics_concordance,
#   by = c("industry_code" = "x2022_naics_code")
# )
# 
# # how many codes are problems
# qcew_converted %>% 
#   inner_join(
#     condensed_naics,
#     by = c("industry_code" = "x2022_naics_code")
#   ) %>% 
#   distinct(industry_code) %>% 
#   glimpse()

# how many BLS 6 digit NAICS are there? 1301...
bls_naics %>% 
  filter(str_length(industry_code) == 6) %>% 
  nrow()

bls_naics6 <- bls_naics %>% filter(str_length(industry_code) == 6)

# and what is the overlap with 2022 and 2017 NAICS like?
setdiff(bls_naics6$industry_code, naics_concordance$x2022_naics_code)
setdiff(bls_naics6$industry_code, naics_concordance$x2017_naics_code)

setdiff(naics_concordance$x2022_naics_code, bls_naics6$industry_code)

# understand NAICS label
bls_naics6 %>% 
  mutate(title_clean = str_remove(industry_title, "NAICS(\\d{2})? \\d{6} ")) %>% 
  distinct(industry_code, title_clean) %>% 
  View()

#============================#
# EXPORT
#============================#

# clean up the description field, add year flag, export
bls_naics6 %>% 
  rename("industry_title_full" = "industry_title") %>% 
  mutate(
    naics_year = if_else(
      str_detect(industry_title_full, "NAICS\\d{2}"),
      str_extract(industry_title_full, "NAICS\\d{2}"), 
      "22"
    ),
    industry_title = str_remove(industry_title_full, "NAICS(\\d{2})? \\d{6} ")
  ) %>% 
write_csv(BLS_NAICS6_FILE)


naics_concordance %>% 
  saveRDS("data/naics_2017_to_2022_concordance.Rds")