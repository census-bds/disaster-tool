#==========================================================#
# SET UP PACKAGES AND API KEYS 
# Run me once!
# 2022-12-02
#==========================================================#

print("installing required packages...")

# list of required packages - these will install their own dependencies
package_list <- c(
  "tidyverse",
  "tidycensus",
  "janitor",
  "censusapi",
  "blscrapeR",
  "readxl",
  "tmap",
  "assertthat"
)

# install them
lapply(package_list, install.packages, character.only=TRUE)

print("done installing packages.")

#============================#
# API KEYS

print("saving API keys for BLS and Census in user .Renviron...")

library(tidycensus)
library(blscrapeR)

CENSUS_API_KEY <- readline(prompt = "Paste your Census API key in the console, then hit enter:")
BLS_API_KEY <- readline(prompt = "Paste your BLS API key in the console, then hit enter:")

# key installation: neither will overwrite an existing key in .Renviron
census_api_key(key, overwrite = FALSE, install = TRUE)
set_bls_key(BLS_API_KEY, overwrite = FALSE)


# since this is the same session, need to re-read .Renviron
readRenviron("~/.Renviron")