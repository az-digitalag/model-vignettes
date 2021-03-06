# Function to estimate stomatal parameters with 'plantecophys'
# Uses both ACi and AQ data across entire range of CO2 and PAR conditions
# Excludes PAR < LCPT and CO2 < 45 ppm

Gs_all_byplant_50_LCPT <- function(fileID){# input is ID column from the experiments dataframe
  
  # Required packages
  library(ggplot2)
  library(plantecophys)
  library(dplyr)

  # Read in data
  fileNames <- dir("cleaned_data/", pattern = as.character(fileID), recursive = T)
  
  # Remove if Rd files present (currently, Rd file does not include raw data and cannot be used for stomatal parameter estimation)
  ind <- which(substr(fileNames, 1, 2) == "Rd")
  if(length(ind) > 0){
    fileNames <- fileNames[-1*ind]
  }
  
  df <- data.frame()
  for(i in 1:length(fileNames)){
    # Read in csv
    temp <- read.csv(paste0("cleaned_data/", fileNames[i]))
    
    # Select relevant columns
    temp2 <- subset(temp, select = c(species, rep, obs, time, date, hhmmss, 
                                     CO2_s, Qin, A, gsw, VPDleaf, RHcham, Ca))
    
    # Filter ACi data for CO2 values > 45 ppm
    if(substring(fileNames[i], 1, 2) == "AC"){
      temp3 <- subset(temp2, CO2_s >= 45)
    }
    
    
    # Filter AQ data for Qin >  LCPT (estimated)
    if(substring(fileNames[i], 1, 2) == "AQ"){
      lparams <- read.csv(paste0("outputs/AQ/", dir("outputs/AQ/", pattern = as.character(fileID))))
      temp3 <- rbind.data.frame(subset(temp2, rep == "plant_1" & Qin >= lparams$Value[lparams$trait == "LCPT" & lparams$rep == "plant_1"]),
                                subset(temp2, rep == "plant_2" & Qin >= lparams$Value[lparams$trait == "LCPT" & lparams$rep == "plant_2"]),
                                subset(temp2, rep == "plant_3" & Qin >= lparams$Value[lparams$trait == "LCPT" & lparams$rep == "plant_3"])
      )
    }
    
    
    # Combine
    df <- rbind.data.frame(df, temp3)
  }
  
  # Split by plant
  dflist <- split(df, df$rep)
  
  # Use 'plantecophys' to estimate stomatal parameters for Ball-Berry and Medlyn models
  # Declare empty dataframe
  out <- data.frame()
  
  # Loop through each plant replicate
  for(i in 1:length(dflist)){
    
    
    # First: fit Medlyn et al. (2011) equation
    gsfit  <- fitBB(dflist[[i]], varnames= list(ALEAF="A", GS= "gsw", VPD="VPDleaf", Ca="Ca", RH="RHcham"), 
                    gsmodel=c("BBOpti"), fitg0 = T) 
    g1M     <- summary(gsfit$fit)$parameters[1]				# save g1 from fitted model
    g0M     <- summary(gsfit$fit)$parameters[2]	      # save g0 from fitted model
    g1M_se  <- summary(gsfit$fit)$parameters[1,2]     # save standard error of g1
    g0M_se  <- summary(gsfit$fit)$parameters[2,2]     # save standard error of g0
    
    # Second: fit the Ball-Berry (1987) model    
    gsfit2  <- fitBB(dflist[[i]], varnames= list(ALEAF="A", GS= "gsw", VPD="VPDleaf", Ca="Ca", RH="RHcham"), 
                     gsmodel=c("BallBerry"), fitg0 = T) 
    g1BB     <- summary(gsfit2$fit)$parameters[1]				
    g0BB     <- summary(gsfit2$fit)$parameters[2]	
    g1BB_se  <- summary(gsfit2$fit)$parameters[1,2] 
    g0BB_se  <- summary(gsfit2$fit)$parameters[2,2]    
    
    # create vector of data for output file (site, species, g1, ci_low, ci_hig)
    temp <- data.frame(ID = rep(fileID, 4),
                      rep = rep(names(dflist)[i], 4),
                      trait = c("g0M", "g1M", "g0BB", "g1BB"),
                      Value = c(g0M, g1M, g0BB, g1BB),
                      SE = c(g0M_se, g1M_se, g0BB_se, g1BB_se),
                      SD = rep(NA, 4),
                      Date.run = rep(as.Date(Sys.time()), 4))
    
    out <- rbind.data.frame(out, temp)
    
  }
  
  # Location of output files
  if(dir.exists("outputs/stomatal/all_byplant_50_LCPT") == F){
    dir.create("outputs/stomatal/all_byplant_50_LCPT", recursive = TRUE)
  }
  loc <- paste0("outputs/stomatal/all_byplant_50_LCPT/")

  write.csv(out, file = paste0(loc, fileID, "_parameters_all_byplant_50.csv"), row.names = F)
  
  # Plotting 
  # Visualize across 2 replicates
  # create dataframe for plotting
  DF <- data.frame(rep = rep(df$rep, 2),
                   gsw = rep(df$gsw, 2),
                   x = c(df$A*df$RHcham/df$Ca/100, #divide RH/100
                         df$A/(df$CO2_s*sqrt(df$VPDleaf))),
                   type = c(rep("BB", nrow(df)), rep("M", nrow(df))))
  params <- data.frame(type = rep(c("M", "BB"), 3),
                       rep = rep(names(dflist), each=2),
                       slope = out$Value[out$trait %in% c("g1BB", "g1M")],
                       int = out$Value[out$trait %in% c("g0BB", "g0M")])
  
  # Medlyn model is not strictly linear, therefore no line shows up
  
  fig_stomatal <- ggplot()+
    geom_point(data = DF, aes(x = x, y = gsw))+
    geom_abline(data = params, aes(slope = slope, intercept = int))+
    facet_grid(rep ~ type, scales = "free")+
    scale_y_continuous(expression(paste(g[sw])))+
    theme_bw()
  
  pdf(paste0(loc, "diagnostic/", fileID, "_stomatal_curves.pdf"), width = 4, height = 6)
  print(fig_stomatal)
  dev.off()
}
  
  

  