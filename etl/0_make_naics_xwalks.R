#==========================================================#
# CONVERT NAICS VINTAGES
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

# qcew <- readRDS("data/QCEW_FL_2022Q1.Rds")

# load 2017 to 2022 NAICS concordance file
naics_concordance <- read_excel(
  "data/2017_to_2022_NAICS.xlsx",
  skip=2,
  col_types = "text"
) %>% 
  clean_names() %>% 
  select(contains("2017"), contains("2022")) %>% 
  rename("x2017_naics_title" = "x2017_naics_title_and_specific_piece_of_the_2017_industry_that_is_contained_in_the_2022_industry")

#============================#
# ANALYSIS, TO CHECK
#============================#

# how many six-digit NAICS were condensed between 2017 and 2022? 
condensed_naics <- naics_concordance %>% 
  count(x2022_naics_code) %>% 
  filter(n > 1) # 79

# what sectors?
condensed_naics %>% 
  mutate(sector = str_sub(x2022_naics_code, 1, 2)) %>% 
  count(sector)
# mostly retail


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

#============================#
# EXPORT
#============================#

naics_concordance %>% 
  saveRDS("data/naics_2017_to_2022_concordance.Rds")
