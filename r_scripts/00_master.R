# ******************************************************************************
# Project: Dissertation
# Task:    Execute all the R scripts
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("magrittr" # Allow pipe operator
       )

load_packages(p)

# ______________________________________________________________________________
# Execute all R scripts

# (1) Extract ESS country-specific data for Germany
file.path("r_scripts", "01_essDE.R") %>% source()

# (2) Extract ESS country-specific data for Slovenia
file.path("r_scripts", "02_essSI.R") %>% source()

# (3) Import ESS data and create tidy dataset
file.path("r_scripts", "03_ess.R") %>% source()

# (4) Import V-Dem data and create tidy dataset
file.path("r_scripts", "04_vdem.R") %>% source()

# (5) Generate exposure to repression data
file.path("r_scripts", "05_vdem_repress.R") %>% source()

# (6) Import German regional data and calculate gap in GDP per capita
#     between Eastern and Western Germany
file.path("r_scripts", "06_vgrdl.R") %>% source()

# (7) Import World Bank data and create tidy dataset
file.path("r_scripts", "07_wb.R") %>% source()

# (8) Import Boix-Miller-Rosato (BMR) data and create tidy dataset
file.path("r_scripts", "08_bmr.R") %>% source()

# (9) Import EVS data
file.path("r_scripts", "09_evs.R") %>% source()

# (10) Merge micro and macro data
file.path("r_scripts", "10_merge.R") %>% source()

# (11) Create map  
file.path("r_scripts", "11_map.R") %>% source()

# (12) Calculate available income East/West Germany (Chap. 6)  
file.path("r_scripts", "12_chap6_available_income.R") %>% source(echo = TRUE)
