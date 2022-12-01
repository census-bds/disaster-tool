
# # debug
# porths_endpoint <- "https://api.census.gov/data/timeseries/intltrade/imports/porths"
# 
# 
# req <- httr::GET(porths_endpoint,
#           query = list(
#             key = census_key,
#             get = "PORT,I_COMMODITY,I_COMMODITY_LDESC,GEN_VAL_MO",
#            time = "2022-09",
#             COMM_LVL = "HS6",
#             I_COMMODITY = "200989"
#           )
# )
# req$url
# raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
# jsonlite::validate(httr::content(req, as = "text"))


