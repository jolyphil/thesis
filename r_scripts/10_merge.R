# ******************************************************************************
# Project: Dissertation
# Task:    Merge micro and macro data
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "haven" # Export to Stata
       )

load_packages(p)

# ______________________________________________________________________________
# Load datasets ----

ess <- file.path("data", "temp", "ess.rds") %>% 
  readRDS()

vdem <- file.path("data", "temp", "vdem.rds") %>%
  readRDS() 

wb <- file.path("data", "temp", "wb.rds") %>% 
  readRDS()

bmr <- file.path("data", "temp", "bmr.rds") %>% 
  readRDS()

exposure <- file.path("data", "temp", "exposure.rds") %>% 
  readRDS()

evs <- file.path("data", "temp", "evs.rds") %>% 
  readRDS()

# ______________________________________________________________________________
# Merge datasets ----

master <- ess %>% 
  left_join(vdem, by = c("country", "year")) %>%
  left_join(wb, by = c("country", "year")) %>%
  left_join(bmr, by = c("country", "year")) %>%
  left_join(exposure, by = c("country", "year", "yrbrn")) %>%
  left_join(evs, by = c("country")) %>%
  arrange(country) %>%
  filter(democracy == 1) # Keep only democracies

rm(ess, vdem, wb, bmr, exposure, evs)

# ______________________________________________________________________________
# Count available country-waves ----
  
master <- master %>% 
  group_by(country, essround) %>% 
  summarize() %>% 
  group_by(country) %>% 
  summarise(n_cw = n()) %>%
  left_join(master, ., by = "country")

# ______________________________________________________________________________
# Keep countries with at least three waves ----

master <- master %>%
  filter(n_cw >= 3)

# ______________________________________________________________________________
# Create liberation variable ----

master <- master %>%
  mutate(liberation_clr = exposure_clr - clr_lag) %>%
  mutate(liberation_piv = exposure_piv - piv_lag)

attr(master$liberation_clr, "label") <- "Liberation, civil liberties restrictions"
attr(master$liberation_piv, "label") <- "Liberation, personal integrity violations"
# ______________________________________________________________________________
# reorder variables ----

master <- master  %>% 
  dplyr::select(essround,
                idno,
                country,
                countrywave,
                year,
                period,
                dweight,
                demonstration,
                petition,
                boycott,
                female,
                age10,
                agerel,
                yrbrn,
                cohort,
                gen1989,
                country_yrbrn,
                edu,
                unemp,
                partygroup,
                union,
                native,
                city,
                class5,
                eastsoc,
                land_de,
                exposure_clr,
                exposure_clr_7_17,
                exposure_piv,
                exposure_piv_7_17,
                liberation_clr,
                liberation_piv,
                postcommunist,
                polyarchy_lag,
                lgdp_lag,
                earlyprotest)

# ______________________________________________________________________________
# Save master dataset

file.path("data", "master.rds") %>%
  saveRDS(master, file = .) 

file.path("data", "master.dta") %>%
  write_dta(master, path = .) 

# ______________________________________________________________________________
# Clear

rm(load_one_package,
   load_packages,
   master,
   p)

gc()
