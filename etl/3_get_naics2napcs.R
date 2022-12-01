#==========================================================#
# GET ECON CENSUS DATA FOR NAICS TO NAPCS XWALK
# Depends: internet access
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

# input files
NAPCS_CONCORDANCE_FILE <- "data/2017_to_2022_NAPCS_Concordance_Final_08242022.xlsx"
NATL_ECON_CENSUS_FILE <- "data/EC1700NAPCSINDPRD.dat"


#TODO: make this ETL nicer by downloading from the FTP, unzipping, etc

# load NAICS to NAPCS allocation factors
naics2napcs <- readRDS("data/natl_six_digit_EC1700NAPCSINDPRD.Rds") %>% 
  filter(NAPCS2017 != "0000000000") 

naics2napcs %>% 
  select(
    contains("NAICS2017"),
    contains("NAPCS2017"),
    contains("ESTAB"),
    contains("LINEALL_"),
    contains("LINE_")
  ) %>% 
  write_csv("tableau/naics2napcs.csv")