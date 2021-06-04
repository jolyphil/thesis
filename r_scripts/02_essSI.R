# ******************************************************************************
# Project: Dissertation
# Task:    Extract ESS country-specific data for Slovenia
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "haven", # Converts SPSS files to R objects
       "stringr" # Performs string operations
)

load_packages(p)

# ______________________________________________________________________________
# Find paths to country-specific datasets ====

spssfiles <- file.path("data", "raw") %>% 
  list.files() %>%
  .[(str_detect(., "ESS[:digit:]csSI.(por|sav)"))]

# ______________________________________________________________________________
# Save datasets as RDS ====

for (i in seq_along(spssfiles)) {
  
  rootname <- str_sub(spssfiles[i], end = -5)
  
  spssfilepath <- file.path("data", "raw", spssfiles[i])
  
  rdsfilepath <- file.path("data", "temp", paste0(rootname, ".rds"))
  
  temp <- read_spss(spssfilepath)
  
  # Rename variable names to lowercase
  names(temp) <- names(temp) %>% 
    tolower()
  
  rdsfilepath %>% saveRDS(temp, file = .)
}

# ______________________________________________________________________________
# Clear ====

rm("i",
   "load_one_package",
   "load_packages",
   "p",
   "rdsfilepath",
   "rootname",
   "spssfilepath",
   "spssfiles",
   "temp")
