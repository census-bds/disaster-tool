#==========================================================#
# TRY DATA FROM THE FTP SITE 
#
#
#==========================================================#

libs <- c(
          "tidyverse",
          "magrittr",
          "janitor",
          "here"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

table <- read_delim("data/EC1700NAPCSINDPRD.dat")

# how many six digit NAICS covered at the national level?
table %>% 
  filter(
    ST == "00",
    str_length(NAICS2017) == 6
  ) %>% 
  nrow()

# do we have all 2-digit NAICS represented?
table %>% 
  filter(
    ST == "00",
    str_length(NAICS2017) == 6
  ) %>%
  distinct(NAICS2017) %>% 
  mutate(short = str_sub(NAICS2017, 1, 2)) %>% 
  distinct(short) %>% 
  nrow() #22

naics_xwalk %>% 
  filter(str_length(industry_code) == 2) %>% 
  distinct(industry_code) %>% 
  nrow() # 19???

anti_join(
  table %>% 
    filter(
      ST == "00",
      str_length(NAICS2017) == 6
    ) %>%
    distinct(NAICS2017) %>% 
    mutate(short = str_sub(NAICS2017, 1, 2)) %>% 
    distinct(short),
  naics_xwalk %>% 
    filter(str_length(industry_code) == 2) %>% 
    distinct(industry_code),
  by = c("short" = "industry_code")
)

# okay conclusion - we have coverage in the FTP table, the mismatch 
# with the crosswalk is the combined NAICS like 31-33

# okay, start with a national six-digit NAICS version
natl_sixdigit <- table %>% 
  filter(
    ST == "00",
    str_length(NAICS2017) == 6
  )

natl_sixdigit %>% 
  filter(!is.na(TVALLN), TVALLN!=0) %>% # I bet 0's are null, gross
  nrow()

# save because it's worth trying it
natl_sixdigit %>% saveRDS("data/natl_six_digit_EC1700NAPCSINDPRD.Rds")
