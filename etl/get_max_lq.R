#==========================================================#
# GET MAX LQ FOR QCEW VARIABLES 
# Cecile Murray
# 2022-10-31
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "tidycensus",
          "readxl"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

#============================#
# LOAD DATA
#============================#

# load FL QCEW
qcew <- readRDS("data/QCEW_FL_2022Q1.Rds")

#============================#
# METHODS
#============================#

# get the max of specified variable
get_max <- function(df, variable) {
  df %>%
    ungroup() %>% 
    select(
      area_fips,
      industry_code,
      industry_title,
      own_code,
      agglvl_code,
      contains("disclosure_code"),
      !!variable
    ) %>%
    filter(
      own_code == 5, # all private jobs
      agglvl_code == 78 # six digit NAICS
    ) %>% 
    group_by(area_fips) %>%
    mutate(
      max_value = max(!!sym(variable)),
      is_max = if_else(max_value == !!sym(variable), 1, 0)
    ) %>%
    filter(is_max == 1) %>% 
    ungroup() %>% 
    select(
      -is_max,
      -all_of(c(variable))
    ) %>% 
    mutate(
      variable = !!variable
    )
}

#============================#
# ANALYSIS
#============================#

# get the following values for each county 
# 1. highest LQ for number of estabs 
# 2. highest LQ for total wages
# 3. highest average monthly LQ for employment


max_lq_estabs <- qcew %>% get_max("lq_qtrly_estabs")

max_lq_wages <- qcew %>% get_max("lq_total_qtrly_wages")

lq_avg_emp <- qcew %>%
  pivot_longer(
    cols = starts_with("lq_month"),
    names_to = "month",
    values_to = "lq_emplvl"
  ) %>% 
  group_by(
    area_fips,
    industry_code,
    own_code
  ) %>% 
  summarize(
    lq_avg_emp = mean(lq_emplvl)
  ) %>% 
  ungroup()

max_lq_avg_emplvl <- qcew %>% 
  left_join(
    lq_avg_emp,
    by = c("area_fips", "industry_code", "own_code")
  ) %>% 
  get_max("lq_avg_emp")

# then combine into one DF
max_lq <- bind_rows(
  max_lq_estabs,
  max_lq_wages,
  max_lq_avg_emplvl
)

# save for convenience
max_lq %>% saveRDS("data/max_lq_QCEW_FL_2022Q1.Rds")

#============================#
# TRY ABSOLUTE ESTAB NUMBERS
#============================#

# 6 suppressions out of 67 isn't bad...
qcew %>% 
  filter(agglvl_code == "78") %>% 
  group_by(area_fips) %>% 
  mutate(
    max_value = max(qtrly_estabs),
    is_max = if_else(max_value == qtrly_estabs, 1, 0)
  ) %>%
  ungroup() %>% 
  filter(is_max == 1) %>% 
  count(disclosure_code)
  
