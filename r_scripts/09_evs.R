# ******************************************************************************
# Project: Dissertation
# Task:    Import EVS data
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("countrycode", # Harmonize country codes
       "dplyr", # Used for data wrangling
       "haven", # Used to import Stata and SPSS files
       "stringr", # Manipulate strings
       "survey" # Handle post-stratification weights
)

load_packages(p)

# ______________________________________________________________________________
# Import EVS data

evs_zip_file <- file.path("data", "raw", "ZA4804_v3-1-0.dta.zip")

dta_file <- evs_zip_file %>%
  unzip(list = TRUE) %>%
  filter(str_detect(Name, ".dta")) %>%
  select(Name) %>%
  as.character()

evs <- unzip(evs_zip_file, 
             files = dta_file,
             exdir = tempdir()) %>%
  read_dta() 

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Reduce dataset ----

evs <- evs %>%
  
  # Keep second wave only
  filter(S002EVS == 2) %>%
  
  # Select useful variables
  select(S003A, S017A, S020, E027, X002)  %>%
  
  # Rename variables
  rename(countrynum = S003A, weight = S017A, year = S020, demonstration = E027, 
         yrbrn = X002) %>%
  
  # Convert country names to ISO3C
  mutate(country = countrycode(as.numeric(countrynum), 'wvs', 'iso3c',
                               custom_match = c("900" = "DEW", 
                                                "901" = "DEE", 
                                                "909" = "NIE"))) 
# ______________________________________________________________________________
# Compute weighted mean

get_subpop_mean <- function(var, cond, weight){
  
  # Assemble variables as "mini" survey
  df <- data.frame(var, cond, weight)
  
  # Save survey design
  dfpc <- svydesign(id = ~1, weights= ~weight, data = df)
  
  # Save subpopulation
  dsub <- subset(dfpc, cond)
  
  # Extract mean of subpopulation
  svymean(~var,design=dsub, na.rm=T)[[1]]
}

evs <- evs %>%
  
  mutate(demonstration = as.numeric(demonstration == 1 & !is.na(demonstration)),
         # Subpopulation: 1989 generation
         gen1989 = yrbrn >= 1964 & yrbrn <= 1972) %>%
  
  group_by(country) %>%
  
  summarize(earlyprotest = get_subpop_mean(var = demonstration,
                                      cond = gen1989,
                                      weight = weight))

# ______________________________________________________________________________
# Attribute labels ----

attr(evs$country, "label") <- "Country code, ISO3C"
attr(evs$earlyprotest, "label") <- "Gen. 1989's exposure to protest"

# ______________________________________________________________________________
# Clean and save main dataset

saveRDS(evs, file = file.path("data", "temp", "evs.rds"))

# clean environment
rm(dta_file,
   evs,
   evs_zip_file,
   get_subpop_mean,
   load_one_package,
   load_packages, 
   p)

gc()
