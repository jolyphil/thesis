# ******************************************************************************
# Project: Dissertation
# Task:    Create map of Europe
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

# ______________________________________________________________________________
# Reference

# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html

# ______________________________________________________________________________

source("r_scripts/functions/load_packages.R")

p <- c("dplyr",
       "ggplot2", 
       "sf", 
       "rnaturalearth", 
       "rnaturalearthdata"
)

load_packages(p)

# ______________________________________________________________________________
# Functions

lbl_to_logical <- function(x){
  x <- x %>%
    as.numeric() %>%
    as.logical()
  x
}

# ______________________________________________________________________________
# Load geographic info for Europe ----

# world <- ne_countries(scale = "medium", returnclass = "sf")
europe <- ne_countries(scale = "small", continent = "europe", returnclass = "sf")

# ______________________________________________________________________________
# Individual-level data ----

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Load Master data ----

master <- file.path("data", "master.rds") %>%
  readRDS()

# ______________________________________________________________________________
# Generate protest data

protest <- master %>%
  select(country, demonstration, petition, boycott, dweight) %>%
  mutate(country = dplyr::if_else(country == "DEE" | country == "DEW", 
                          "DEU", 
                          country)) %>%
  mutate(protest = as.numeric(lbl_to_logical(demonstration) | 
                              lbl_to_logical(petition) |
                              lbl_to_logical(boycott)),
         protest = ifelse(is.na(protest), 0, protest)) %>%
  group_by(country) %>%
  summarize(protest_pct = weighted.mean(protest, dweight, na.rm = T) * 100)

# ______________________________________________________________________________
# Merge geo data with protest data

europe <- europe %>%
  mutate(country = adm0_a3,
         country = ifelse(name == "Kosovo", "XKX", country)) %>%
  left_join(protest)

# ______________________________________________________________________________
# Graph

ggplot(data = europe) +
  geom_sf(aes(fill = protest_pct)) +
  scale_fill_viridis_c() +
  coord_sf(xlim = c(-28, 42), ylim = c(33, 72), expand = FALSE) + 
  labs(fill = "Protesters (%)") + 
  theme_bw() +
  theme(axis.text = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

file.path("figures", "pdf", "fig_1_1_protest_map.pdf") %>%
  ggsave()

# ______________________________________________________________________________
# Stats

# Reload master
protest <- master %>%
  select(country, postcommunist, demonstration, petition, boycott, dweight) %>%
  mutate(protest = as.numeric(lbl_to_logical(demonstration) | 
                              lbl_to_logical(petition) | 
                              lbl_to_logical(boycott)),
         protest = ifelse(is.na(protest), 0, protest)) %>%
  group_by(country) %>%
  summarize(protest_pct = weighted.mean(protest, dweight, na.rm = T) * 100,
            postcommunist = mean(postcommunist))

# Minimum
protest %>% filter(protest_pct == min(protest_pct))

# Maximum
protest %>% filter(protest_pct == max(protest_pct))

# T-test
t.test(protest$protest_pct ~ protest$postcommunist) 

# ______________________________________________________________________________
# Clean environment

rm(europe,
   lbl_to_logical,
   load_one_package,
   load_packages,
   master,
   p,
   protest)

gc()