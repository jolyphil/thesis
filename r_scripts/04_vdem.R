# ******************************************************************************
# Project: Dissertation
# Task:    Import V-Dem data
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/inverse.R")
source("r_scripts/functions/load_packages.R")

p <- c("dplyr" # Used for data wrangling
       )

load_packages(p)

# ______________________________________________________________________________
# Load V-Dem Data 

vdem <- "V-Dem-CY-Core-v9.rds" %>%
  file.path("data", "raw", .) %>%
  readRDS() %>%
  select(country_text_id,
         year,
         v2x_polyarchy,
         v2x_clpol,
         v2x_clphy) %>%
  filter(year >= 2001) %>%
  rename(country = country_text_id,
         polyarchy = v2x_polyarchy,
         clr = v2x_clpol,
         piv = v2x_clphy)

# ______________________________________________________________________________
# Inverse repression variables

vdem <- vdem %>%
  mutate(clr = inverse(clr, type = "bounded", low = 0, high = 1)) %>%
  mutate(piv = inverse(piv, type = "bounded", low = 0, high = 1))

# ______________________________________________________________________________
# Duplicate observations for East and West Germany

vdem <- vdem %>%
  mutate(country = ifelse(country == "DEU", 
                                "DEW", 
                                country)) # Code West Germany

vdem <- vdem %>% 
  filter(country == "DEW") %>%
  mutate(country = "DEE") %>% # Code East Germany
  bind_rows(vdem) %>%
  arrange(country, year)

# ______________________________________________________________________________
# Create lagged measure

vdem <- vdem %>%
  arrange(country, year) %>%
  group_by(country) %>%
  mutate(polyarchy_lag = lag(polyarchy),
         clr_lag = lag(clr),
         piv_lag = lag(piv)) %>%
  ungroup()

# ______________________________________________________________________________
# Create lagged measure

vdem <- vdem %>%
  select(country, year, polyarchy_lag, clr_lag, piv_lag)

# ______________________________________________________________________________
# Attribute labels

attr(vdem$country, "label") <- "Country code, ISO3C"
attr(vdem$year, "label") <- "Year"
attr(vdem$polyarchy_lag, "label") <- "Electoral democracy index, lagged"
attr(vdem$clr_lag, "label") <- "Civil liberties restrictions, lagged"
attr(vdem$piv_lag, "label") <- "personal integrity violations, lagged"

# ______________________________________________________________________________
# Save dataset

file.path("data", "temp", "vdem.rds") %>%
  saveRDS(vdem, file = .) 

# Clean
rm(inverse,
   load_one_package,
   load_packages, 
   p,
   vdem)
gc()
