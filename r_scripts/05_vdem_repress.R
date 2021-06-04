# ******************************************************************************
# Project: Dissertation
# Task:    Generate data on exposure to repression from V-Dem
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/inverse.R")
source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "tidyr" # dataset manipulations
       )

load_packages(p)

# ______________________________________________________________________________
# Load V-Dem Data ----

vdem <- file.path("data", "raw", "V-Dem-CY-Core-v9.rds") %>%
  readRDS() %>%
  select(country_text_id,
         year,
         v2x_clpol,
         v2x_clphy) %>%
  filter(year >= 1919) %>%
  rename(country = country_text_id)

# ______________________________________________________________________________
# East and West Germany: Change Country Code ----

vdem <- vdem %>%
  mutate(country = case_when(country == "DEU" ~ "DEW",
                             country == "DDR" ~ "DEE",
                             T ~ country)) %>%
  filter(!(country == "DEE" & year %in% c(1945:1948))) # Drop empty cells

# ______________________________________________________________________________
# Find countries in ESS dataset ----

ess_countries <- file.path("data", "temp", "ess_country_years.rds") %>%
  readRDS() %>%
  select(country) %>%
  unlist() %>%
  unique()

# ______________________________________________________________________________
# Show incomplete cases ----

vdem %>%
  group_by(country) %>%
  mutate(continuous = (lag(year) == year - 1)) %>%
  summarize(yearmin = min(year),
            yearmax = max(year),
            is_complete = all(continuous) & yearmin == 1919 & yearmax >= 2017) %>%
  filter(is_complete == FALSE & country %in% ess_countries)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# OUTPUT:

#  country minyear maxyear is_complete
#  <chr>        <dbl>   <dbl> <lgl>      
#  1 AUT        1919    2018 FALSE      
#  2 DEE        1949    1990 FALSE      
#  3 DEW        1919    2018 FALSE      
#  4 EST        1919    2018 FALSE      
#  5 HRV        1941    2018 FALSE      
#  6 LTU        1919    2018 FALSE      
#  7 LVA        1920    2018 FALSE      
#  8 POL        1919    2018 FALSE      
#  9 SVK        1939    2018 FALSE      
# 10 SVN        1989    2018 FALSE      
# 11 UKR        1990    2018 FALSE      
# 12 XKX        1999    2018 FALSE   

# ______________________________________________________________________________
# Recode incomplete cases ----

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Load recode scheme

recode_scheme <- file.path("data", "raw", "recode_scheme.rds") %>%
  readRDS()

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Apply recode actions sequentially

for (i in 1:nrow(recode_scheme)) {
  vdem <- vdem %>%
    filter(country == recode_scheme[i, "parentcountry"] & 
                      year >= recode_scheme[i, "periodbegin"] &
                      year <= recode_scheme[i, "periodend"]) %>%
    mutate(country = recode_scheme[i, "country"]) %>%
    bind_rows(vdem)
}

vdem <- vdem %>% 
  arrange(country, year)

# ______________________________________________________________________________
# Interpolate ----

interpolate <- function(data, cntry, yearmin, yearmax) {
  
  # Function: returns a vector of interpolated data
  interpolate_var <- function(var) {
    
    poles <- data %>%
      filter(country == cntry & (year == yearmin | year == yearmax)) %>%
      select(!!var) %>%
      unlist()
    
    r <- approx(c(yearmin, yearmax), poles, n = length(yearmin:yearmax))[[2]] %>%
      round(digits = 3)
    r
  }
  
  # Extract variables to interpolate
  varlist <- names(vdem)[names(vdem) != "country" & names(vdem) != "year"]
  
  # Perform interpolation on each variable
  interpol_list <- lapply(varlist, interpolate_var)
  names(interpol_list) <- varlist
  
  # Assemble replacement data
  replacement_data <- data.frame(country = cntry, 
                                 year = as.numeric(yearmin:yearmax),
                                 interpol_list,
                                 stringsAsFactors = F)
  # Add replacement data to original data
  data <- data %>%
    filter(!(country == cntry & year >= yearmin & year <= yearmax)) %>%
    bind_rows(replacement_data) %>%
    arrange(country, year)
  
  data
}

vdem <- interpolate(vdem, "DEE", 1944, 1949)
vdem <- interpolate(vdem, "DEW", 1944, 1949)

# ______________________________________________________________________________
# Keep ESS countries only ----

vdem <- vdem %>%
  filter(country %in% ess_countries)

# ______________________________________________________________________________
# Find first available year ----

vdem <- vdem %>%
  group_by(country) %>%
  mutate(yearmin = min(year)) %>%
  ungroup()

# ______________________________________________________________________________
# Expand observations ----

vdem <- vdem %>%
  uncount(100) %>%
  group_by(country, year) %>%
  mutate(yrbrn = as.numeric(1904:2003)) %>%
  ungroup() %>%
  mutate(age = year - yrbrn) %>%
  filter(year >= yrbrn) %>%
  arrange(country, yrbrn, year) %>%
  select(country, 
         yearmin, 
         yrbrn, 
         year, 
         age, 
         v2x_clpol, 
         v2x_clphy) # reorder variables

# ______________________________________________________________________________
# Calculate exposure ----

calculate_exposure <- function(data, varname, var, agemin, agemax) {
  
  varname <- enquo(varname)
  var <- enquo(var)
  
  data <- data %>%
    mutate(weight = as.numeric(age >= agemin & age <= agemax), 
           annualexposure = !!var * weight) %>%
    group_by(country, yrbrn) %>%
    mutate(sumexposure = cumsum(annualexposure),
           sumweight = cumsum(weight)) %>%
    ungroup() %>%
    mutate(!!varname := ifelse((age >= agemin) & (yrbrn + agemin >= yearmin),
                             sumexposure / sumweight,
                             NA_real_),
           !!varname := round(!!varname, digits = 3)) %>%
    select(-c(weight, annualexposure, sumexposure, sumweight))
  
  data
}

vdem <- vdem %>%
  calculate_exposure(exposure_clr, v2x_clpol, 15, 25) %>%
  calculate_exposure(exposure_clr_7_17, v2x_clpol, 7, 17) %>%
  calculate_exposure(exposure_piv, v2x_clphy, 15, 25) %>%
  calculate_exposure(exposure_piv_7_17, v2x_clphy, 7, 17) %>%
  mutate(exposure_clr = inverse(exposure_clr, type = "bounded", 
                                     low = 0, high = 1),
         exposure_clr_7_17 = inverse(exposure_clr_7_17, type = "bounded", 
                                    low = 0, high = 1),
         exposure_piv = inverse(exposure_piv, type = "bounded", 
                                  low = 0, high = 1),
         exposure_piv_7_17 = inverse(exposure_piv_7_17, type = "bounded", 
                                  low = 0, high = 1))

# ______________________________________________________________________________
# Reduce size database ----

vdem <- vdem %>%
  filter(year >= 2002) %>% # First round ESS
  filter(age >= 15) %>% # exclude people younger than 15 years ol
  select(country, 
         year, 
         yrbrn, 
         exposure_clr, 
         exposure_clr_7_17,
         exposure_piv,
         exposure_piv_7_17)

# ______________________________________________________________________________
# Attribute labels ----

attr(vdem$country, "label") <- "Country code, ISO3C"
attr(vdem$year, "label") <- "Year"
attr(vdem$yrbrn, "label") <- "Year of birth"
attr(vdem$exposure_clr, "label") <- "Exposure to civil liberties restrictions, 15 to 25 years old"
attr(vdem$exposure_clr_7_17, "label") <- "Exposure to civil liberties restrictions, 7 to 17 years old"
attr(vdem$exposure_piv, "label") <- "Exposure to personal integrity violations, 15 to 25 years old"
attr(vdem$exposure_piv_7_17, "label") <- "Exposure to personal integrity violations, 7 to 17 years old"

# ______________________________________________________________________________
# Save dataset ----

saveRDS(vdem, file = file.path("data", "temp", "exposure.rds")) 

# ______________________________________________________________________________
# Clear environment ----

rm(calculate_exposure,
   ess_countries,
   i,
   interpolate,
   inverse,
   load_one_package,
   load_packages,
   p,
   recode_scheme,
   vdem)

gc()
