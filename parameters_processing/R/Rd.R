# Function to summarize dark-adapted respiration values at the population level
# Only for the outdoor treatments on which AQ curves were not taken
# Rd was measured at 0 PAR after dark-adapting the leaves with foil for ~20 minutes

Rd <- function (fileID){# input is ID column from the experiments dataframe
  
  # Read in data
  df <- read.csv(paste0("~/sentinel-detection/data/cleaned_data/Rd/Rd_", fileID, ".csv"))

  # Location of output files
  if(dir.exists("~/sentinel-detection/data/derived_data/Rd/") == F){
    dir.create("~/sentinel-detection/data/derived_data/Rd/", recursive = TRUE)
  }
  loc <- paste0("~/sentinel-detection/data/derived_data/Rd/")
  
  # Summarize to population level mean and SE
  out <- data.frame(ID = rep(fileID, 1),
                       rep = rep(NA, 1),
                       trait = rep("Rd", 1),
                       Value = mean(df$value),
                       SE = sd(df$value)/sqrt(nrow(df)),
                       SD = sd(df$value),
                       Date.run = rep(as.Date(Sys.time()), 1))
  
  # Write to file
  write.csv(out, file = paste0(loc, fileID, "_parameters.csv"), row.names = F)
}