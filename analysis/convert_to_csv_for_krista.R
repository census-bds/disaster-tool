#==========================================================#
# MAKE CSV VERSIONS OF SLOW API PULLS
# Cecile Murray
# 2022-12-09
#==========================================================#

library(tidyverse)

CTY_QCEW_FILE <- "data/QCEW_CTY_2022Q1.Rds"
PORTS_HS6_FILE <- "data/imports_HS6_ports_2022-09.Rds"

readRDS(CTY_QCEW_FILE) %>% 
  write_csv("data/QCEW_CTY_2022Q1.csv")

readRDS(PORTS_HS6_FILE) %>% 
  write_csv("data/imports_HS6_ports_2022-09.csv")
