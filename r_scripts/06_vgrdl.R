# ******************************************************************************
# Project: Dissertation
# Task:    Import data from the Arbeitskreis "Volkswirtschaftliche 
#          Gesamtrechnungen der Länder" and calculate gap in GDP per capita
#          between East and West Germany
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "magrittr", # Allow pipe operator
       "readxl", # Import Excel data
       "tidyr" # Reshape data
)

load_packages(p)

# ______________________________________________________________________________
# Import raw data ----

vgrdl <- file.path("data", "raw", "R1B1.xlsx") %>%
  read_excel(sheet = "3.3", range = "A3:W32")

# delete two empty rows
vgrdl <- vgrdl[-c(1:2), ]

# ______________________________________________________________________________
# Tidy data ----

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# extract column names ----

names_col <- names(vgrdl)
names_col

# Output:

# [1] "Jahr"                                       "Baden-\r\nWürttemberg"                     
# [3] "Bayern"                                     "Berlin"                                    
# [5] "Branden-\r\nburg"                           "Bremen"                                    
# [7] "Hamburg"                                    "Hessen"                                    
# [9] "Mecklenburg-\r\nVorpommern"                 "Nieder-\r\nsachsen"                        
# [11] "Nordrhein-\r\nWestfalen"                    "Rheinland-Pfalz"                           
# [13] "Saarland"                                   "Sachsen"                                   
# [15] "Sachsen-Anhalt"                             "Schleswig-\r\nHolstein"                    
# [17] "Thüringen"                                  "Deutschland"                               
# [19] "alte Bundesländer\r\neinschließlich Berlin" "alte Bundesländer\r\nohne Berlin"          
# [21] "neue Bundesländer\r\neinschließlich Berlin" "neue Bundesländer\r\nohne Berlin"          
# [23] "Deutschland__1"   

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Select columns, gather, calculate gap ----

vgrdl <- vgrdl %>% 
  rename(year = "Jahr",
         DEW = names_col[20], # Old Länder, without Berlin
         DEE = names_col[22], # New Länder, without Berlin
         gdp_de = names_col[23]) %>% # Germany as a whole 
  select(year, DEW, DEE, gdp_de) %>%
  gather(c("DEW", "DEE"), key = "country", value = "gdp") %>%
  mutate(gap = gdp/gdp_de) %>% # calculate East-West Gap
  select(country, year, gap)

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Graph ----

# library(ggplot2)
# f <- ggplot(vgrdl, aes(x = year, y = gap, colour = country))
# f + geom_line(aes(group = country))

# ______________________________________________________________________________
# Save ----

saveRDS(vgrdl, file = file.path("data", "temp", "vgrdl.rds"))

# Clean
rm(load_one_package,
   load_packages,
   names_col, 
   p,
   vgrdl)

gc()
