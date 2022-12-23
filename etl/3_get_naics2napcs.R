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
          "readxl",
          "censusapi"
)
invisible(suppressMessages(lapply(libs, library, character.only=TRUE)))

census_key <- Sys.getenv("CENSUS_API_KEY")

options(scipen = 999) # to eliminate scientific notation in NAPCS codes

FTP_URL <- "https://www2.census.gov/programs-surveys/economic-census/data/2017/sector00/EC1700NAPCSINDPRD.zip"

# intermediate files
ECON_CENSUS_ZIP_FILE <- "data/EC1700NAPCSINDPRD.zip"
NATL_ECON_CENSUS_FILE <- "data/EC1700NAPCSINDPRD.dat"

# output
NAICS2NAPCS_FILE <- "tableau/naics2napcs.csv"


#============================#
# GET DATA
#============================#

# download the zip file from the FTP site
return_code <- download.file(
  url = FTP_URL, 
  destfile = ECON_CENSUS_ZIP_FILE, 
  method = "curl",
  mode = "wb"
  ) 

# if we were successful, unzip
if (return_code == 0) {
   unzip(
     ECON_CENSUS_ZIP_FILE, # zip file
     overwrite = TRUE # overwrite existing files
   )
# otherwise throw an error
} else {
  stop("file download was not successful")
}

#============================#
# READ, CLEAN, CONVERT TO CSV
#============================#

# load NAICS to NAPCS allocation factors
naics2napcs <- read_delim(NATL_ECON_CENSUS_FILE) %>% 
  filter(
    NAPCS2017 != "0000000000", # filter out total code
    `#GEOTYPE` == "01"
  )

naics2napcs %>% 
  select(
    contains("NAICS2017"),
    contains("NAPCS2017"),
    contains("ESTAB"),
    contains("LINEALL_"),
    contains("LINE_")
  ) %>% 
  write_csv(NAICS2NAPCS_FILE)