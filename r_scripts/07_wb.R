# ******************************************************************************
# Project: Dissertation
# Task:    Import World Bank data and create tidy dataset
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "wbstats" # Load world Bank data
       )

load_packages(p)

# ______________________________________________________________________________
# Import World Bank Raw Data (run this code to import raw data again)

# wbsearch(pattern = "GDP per Capita") %>% tibble()
# 
# # NY.GDP.PCAP.PP.KD: GDP per capita, PPP (constant 2011 international $)
# wb <- wb(indicator = "NY.GDP.PCAP.PP.KD", 
#           startdate = 2001, 
#           enddate = 2017,
#           return_wide = TRUE)
# 
# saveRDS(wb, file = file.path("data", "raw", "wb_gdp.rds")) 

# ______________________________________________________________________________
# Select and recode variables

wb <- file.path("data", "raw", "wb_gdp.rds") %>%
  readRDS() %>%
  select(-country) %>%
  rename(country = "iso3c",
         year = "date",
         gdp = "NY.GDP.PCAP.PP.KD") %>%
  mutate(year = as.numeric(year))

# ______________________________________________________________________________
# Adjust values for East and West Germany

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Duplicate observations for Germany ----

wb <- wb %>%
  mutate(country = ifelse(country == "DEU", "DEW", country)) # Code West Germany

wb <- wb %>% 
  filter(country == "DEW") %>%
  mutate(country = "DEE") %>% # Code East Germany
  bind_rows(wb)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Merge with VGRDL data ----

vgrdl <- readRDS(file = file.path("data", "temp", "vgrdl.rds")) 

wb <- wb %>% 
  left_join(vgrdl, by = c("country", "year"))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Adjust GDP with VGRDL data ----

wb <- wb %>% 
  mutate(gdp = ifelse(!is.na(gap), gdp * gap, gdp))

# ______________________________________________________________________________
# Rescale

wb <- wb %>%
  mutate(lgdp = log(gdp))

# ______________________________________________________________________________
# Create lagged measure

wb <- wb %>%
  arrange(country, year) %>%
  group_by(country) %>%
  mutate(lgdp_lag = lag(lgdp)) %>%
  ungroup()

# ______________________________________________________________________________
# Select variables

wb <- wb %>%
  dplyr::select(country, year, lgdp_lag) %>%
  arrange(country, year)

# ______________________________________________________________________________
# Attribute labels

attr(wb$country, "label") <- "Country code, ISO3C"
attr(wb$year, "label") <- "Year"
attr(wb$lgdp_lag, "label") <- "GDP per capita, PPP (constant 2011 international $), log transformation, lagged"

# ______________________________________________________________________________
# Save dataset

saveRDS(wb, file = file.path("data", "temp", "wb.rds")) 

# Clean
rm(load_one_package,
   load_packages, 
   p,
   vgrdl,
   wb)

gc()
