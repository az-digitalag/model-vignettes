# Load required libraries
# ----------------------------------------------------------------------
library(readxl)
library(udunits2)
library(dplyr)
library(tidyr)
library(ggplot2)

if(!dir.exists(paste0("../plots/"))){
  dir.create(paste0("../plots/"), recursive = T)
}

# Organize 3 treatments into same figure
treatments <- c("ch", "gh", "out")

biomass_ts <- c()
trans_ts <- c()
for (trt in treatments) {
  data_in <- read.csv(paste0("/data/output/pecan_runs/env_comp_results/", trt, 
                        "/ensemble_ts_summary_AGB.csv")) %>%
    mutate(treatment = trt) %>%
    relocate(treatment)
  biomass_ts <- rbind(biomass_ts, data_in)
  
  data_in <- read.csv(paste0("/data/output/pecan_runs/env_comp_results/", trt, 
                         "/ensemble_ts_summary_TVeg.csv")) %>%
    mutate(treatment = trt) %>%
    relocate(treatment)
  trans_ts <- rbind(trans_ts, data_in)
}

# Bring in validation biomass
load("~/sentinel-detection/data/cleaned_data/biomass/chamber_biomass.Rdata")
load("~/sentinel-detection/data/cleaned_data/biomass/greenhouse_outdoor_biomass.Rdata")

biomass_valid_ch <- chamber_biomass %>%
  filter(genotype == "ME034V-1" &
           treatment %in% c(NA, "control") &
           temp == "31/22" &
           light == 430 &
           !is.na(stem_DW_mg) &
           !is.na(leaf_DW_mg) &
           !is.na(panicle_DW_mg)) %>%
  rename(plant_id = plantID) %>%
  mutate(location = "ch",
         stem_DW_g = ud.convert(stem_DW_mg, "mg", "g"),
         leaf_DW_g = ud.convert(leaf_DW_mg, "mg", "g"),
         panicle_DW_g = ud.convert(panicle_DW_mg, "mg", "g")) %>%
  dplyr::select(location, plant_id, sowing_date, transplant_date, harvest_date,
         stem_DW_g, leaf_DW_g, panicle_DW_g)

biomass_valid_gh_out <- greenhouse_outdoor_biomass %>%
  filter(genotype == "ME034V-1" &
           treatment %in% c("pot", "jolly_pot") &
           !is.na(stem_DW_g) &
           !is.na(leaf_DW_g) &
           !is.na(panicle_DW_g) & 
           exp_site == "GH" & exp_number == 1 |
           genotype == "ME034V-1" &
           treatment %in% c("pot", "jolly_pot") &
           !is.na(stem_DW_g) &
           !is.na(leaf_DW_g) &
           !is.na(panicle_DW_g) & 
           exp_site == "Field" & exp_number == 2) %>%
  mutate(location = case_when(exp_site == "GH" ~ "gh",
                              exp_site == "Field" ~ "out")) %>%
  dplyr::select(location, plant_id, sowing_date, transplant_date, harvest_date,
         stem_DW_g, leaf_DW_g, panicle_DW_g)

# Combine
biomass_valid <- rbind(biomass_valid_ch, biomass_valid_gh_out) %>%
  rename(treatment = location) %>%
  mutate(agb_kg_m2 = ud.convert((stem_DW_g + leaf_DW_g + panicle_DW_g)/103,
                                          "g/cm2", "kg/m2"),
         day = difftime(harvest_date, sowing_date, units = "days"))

# Plot measured biomass against biomass estimates
fig_biomass_ts <- ggplot() +
  geom_line(data = biomass_ts, aes(day, y = median, color = treatment)) +
  geom_ribbon(data = biomass_ts, aes(day, ymin = lcl_50, ymax = ucl_50, fill = treatment), 
              alpha = 0.25) +
  geom_point(data = biomass_valid, aes(day, y = agb_kg_m2, color = treatment)) +
  scale_x_continuous("Day of experiment") + 
  scale_y_continuous(expression(paste("Aboveground biomass (kg ",  m^-2, ")"))) +
  theme_classic()

jpeg(filename = "../plots/biomass_ts.jpg", height = 5, width = 7, units = "in", res = 600)
print(fig_biomass_ts)
dev.off()

fig_trans_ts <- ggplot() +
  geom_line(data = trans_ts, aes(day, y = median, color = treatment)) +
  geom_ribbon(data = trans_ts, aes(day, ymin = lcl_50, ymax = ucl_50, fill = treatment), 
              alpha = 0.25) +
  scale_x_continuous("Day of Experiment") + 
  scale_y_continuous(expression(paste("Canopy Transpiration (kg ",  m^-2, " ", day^-1, ")"))) +
  theme_classic()

jpeg(filename = "../plots/trans_ts.jpg", height = 5, width = 7, units = "in", res = 600)
print(fig_trans_ts)
dev.off()
