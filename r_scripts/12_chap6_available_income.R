# ******************************************************************************
# Project: Dissertation
# Task:    Import data from the "Statistische Ämter des Bundes und der Länder"
#          and calculate gap in available income between East and West Germans
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "ggplot2", # Graphs
       "rvest", # Scrape website
       "stringr", # String operations
       "tidyr" # Use to reshape data
)

load_packages(p)

# ______________________________________________________________________________
# Available income ====

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Parse html file ====

url <- "data/raw/vgrdl_available_income.html"
url_parsed <- read_html(url)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Extract raw table ====

xpath <- "//*[@id=\"tab01\"]"

income <- html_nodes(url_parsed, xpath = xpath) %>% 
  
  html_table(fill = TRUE) %>%
  
  .[[1]]

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Clean table ====

colnames(income) <- income[2,] # Assign column names
income <- income[4:30, ] # select rows

for (i in 1:ncol(income)) {
  income[ , i] <- str_replace_all(income[ , i], "[:punct:]", "")
  income[ , i] <- as.numeric(income[ , i])
  if (i > 1) {
    income[ , i] <- income[ , i] * 10^6
  }
}

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Calculate values for East and West Germany (without Berlin) ====

income <- income %>%
  mutate(DEE = BB + MV + SN + ST + TH,
         DEW = BW + BY + HB + HH + HE + NI + NW + RP + SL + SH)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Tidy data ====

income <- income %>%
  rename(year = Jahr) %>%
  select(DEE, DEW, year) %>%
  pivot_longer(-year, names_to = "region", values_to = "income") %>% 
  select(region, year, income) %>%
  arrange(region, year)

# ______________________________________________________________________________
# Population ====

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Parse html file ====

url <- "data/raw/vgrdl_population.html"
url_parsed <- read_html(url)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Extract raw table ====

xpath <- "//*[@id=\"tab01\"]"

population <- html_nodes(url_parsed, xpath = xpath) %>% 
  
  html_table(fill = TRUE) %>%
  
  .[[1]]

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Clean table ====

colnames(population) <- population[2,] # Assign column names
population <- population[4:30, ] # select rows

for (i in 1:ncol(population)) {
  population[ , i] <- str_replace_all(population[ , i], "[:punct:]", "")
  population[ , i] <- as.numeric(population[ , i])
  if (i > 1) {
    population[ , i] <- population[ , i] * 1000
  }
}

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Calculate values for East and West Germany (without Berlin) ====

population <- population %>%
  mutate(DEE = BB + MV + SN + ST + TH,
         DEW = BW + BY + HB + HH + HE + NI + NW + RP + SL + SH)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Tidy data ====

population <- population %>%
  rename(year = Jahr) %>%
  select(DEE, DEW, year) %>%
  pivot_longer(-year, names_to = "region", values_to = "population") %>% 
  select(region, year, population) %>%
  arrange(region, year)

# ______________________________________________________________________________
# Merge ====

master <- income %>%
  left_join(population) %>%
  mutate(inc_per_capita = income / population)

# ______________________________________________________________________________
# Plot ====

# ggplot(data=master, aes(x=year, y=inc_per_capita, group=region)) +
#   geom_line(aes(color=region)) + 
#   geom_point(aes(color=region))

# ______________________________________________________________________________
# Print values ====

ratio <- function(data, year) {
  dee <- data$inc_per_capita[data$region == "DEE" & data$year == year]
  dew <- data$inc_per_capita[data$region == "DEW" & data$year == year]
  ratio <- round((dee / dew) * 100, digits = 0) %>%
    paste0(., "%")
  ratio
} 

ratio(master, 1991)
ratio(master, 2017)

# ______________________________________________________________________________
# Clean environment

rm(i,
   income,
   load_one_package,
   load_packages,
   master,
   p,
   population,
   ratio,
   url,
   url_parsed,
   xpath)

gc()
