# ******************************************************************************
# Project: Dissertation
# Task:    Import Boix-Miller-Rosato (BMR) data and create tidy dataset
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("countrycode", # Harmonizes country codes
       "dplyr", # Used for data wrangling
       "haven", # Import Stata dta files
       "readr" # Import CSV files
)

load_packages(p)

# ______________________________________________________________________________
# Import Boix-Miller-Rosato (BMR) data ---- 

bmr <- file.path("data", "raw", "democracy-v3.0.csv") %>%
  read_csv() %>%
  rename(country_name = country) %>%
  mutate(country = countrycode(ccode, 'cown', 'iso3c')) %>%
  select(country_name, ccode, country, year, democracy) %>%
  mutate(country = ifelse(country_name == "KOSOVO", "XKX", country)) %>%
  filter(year >= 2002 & !is.na(democracy))

# ______________________________________________________________________________
# Expand observations for 2016 and 2017 using VDem data ---- 

vdem_extra <- file.path("data", "raw", "V-Dem-CY-Core-v9.rds") %>%
  readRDS() %>%
  filter(year > 2015) %>%
  select(country_name, country_text_id, year, v2x_regime) %>%
  rename(country = country_text_id) %>%
  mutate(democracy = ifelse(v2x_regime >= 2, 1, 0),
         ccode = NA) %>%
  select(country_name, ccode, country, year, democracy)
  

# ______________________________________________________________________________
# Append V-Dem data ---- 

bmr <- bmr %>% 
  bind_rows(vdem_extra) %>%
  mutate(vdem_extra = (year > 2015)) %>%
  arrange(country, year)

# ______________________________________________________________________________
# Examine cases where country code attribution failed ----

bmr %>%
  filter(is.na(country)) %>%
  group_by(country_name, ccode) %>%
  summarize(yearmin = min(year),
            yearmax = max(year))

# Output: 

#   country_name          ccode yearmin yearmax
#   <chr>                 <dbl>   <dbl>   <dbl>
# 1 ETHIOPIA                529    2002    2015 --> ignore, not in ESS
# 2 MONTENEGRO              348    2006    2015 --> ignore, not in ESS
# 3 SERBIA                  342    2006    2015 --> ignore, not in ESS
# 4 SUDAN, NORTH            624    2011    2015 --> ignore, not in ESS
# 5 VIETNAM                 818    2002    2015 --> ignore, not in ESS
# 6 YUGOSLAVIA, FED. REP.   347    2002    2006 --> ignore, not in ESS

# ______________________________________________________________________________
# Duplicate observations for East and West Germany

bmr <- bmr %>%
  mutate(country = ifelse(country == "DEU", "DEW", country)) # Code West Germany

bmr <- bmr %>% 
  filter(country == "DEW") %>%
  mutate(country = "DEE") %>% # Code East Germany
  bind_rows(bmr) %>%
  arrange(country, year)

# ______________________________________________________________________________
# Labels democracy

bmr <- bmr %>%
  mutate(democracy = labelled(democracy, 
                              labels = c("Non democracy" = 0, "Democracy" = 1),
                              label = "Dichotomous democracy measure"))

# ______________________________________________________________________________
# Select variables

bmr <- bmr %>%
  select(country, year, democracy)

# ______________________________________________________________________________
# Attribute labels

attr(bmr$country, "label") <- "Country code, ISO3C"
attr(bmr$year, "label") <- "Year"

# ______________________________________________________________________________
# Save dataset

file.path("data", "temp", "bmr.rds") %>%
  saveRDS(bmr, file = .) 

# Clean
rm(bmr,
   load_one_package,
   load_packages, 
   p,
   vdem_extra)
gc()

