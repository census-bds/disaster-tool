#==========================================================#
# EXPLORE NAICS/NAPCS CROSSWALK
# Cecile Murray
# 2022-11-03
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here",
          "dbplyr"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))


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
