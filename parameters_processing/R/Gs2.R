# Function to estimate stomatal parameters with 'plantecophys'
# Uses both ACi and AQ data across entire range of CO2 and PAR conditions
# Excludes PAR < LCPT and CO2 < 45 ppm
# Identical to Gs_all_byplant_50_LCPT.R except where outputs are saved and how they are named

Gs <- function(fileID){# input is ID column from the experiments dataframe
  
  # Required packages
  require(ggplot2)
  require(plantecophys)
  require(dplyr)

  # Read in data
  fileNames <- dir("~/sentinel-detection/data/cleaned_data/", pattern = as.character(fileID), recursive = T)
  
  # Remove if Rd files present (currently, Rd file does not include raw data and cannot be used for stomatal parameter estimation)
  ind <- which(substr(fileNames, 1, 2) == "Rd")
  if(length(ind) > 0){
    fileNames <- fileNames[-1*ind]
  }
  
  df <- data.frame()
  for(i in 1:length(fileNames)){
    # Read in csv
    temp <- read.csv(paste0("~/sentinel-detection/data/cleaned_data/", fileNames[i]))
    
    # Select relevant columns
    temp2 <- subset(temp, select = c(species, rep, obs, time, date, hhmmss, 
                                     CO2_s, Qin, A, gsw, VPDleaf, RHcham, Ca))
    
    # Filter ACi data for CO2 values > 45 ppm
    if(substring(fileNames[i], 1, 2) == "AC"){
      temp3 <- subset(temp2, CO2_s >= 45)
    }
    
    
    # Filter AQ data for Qin >  LCPT (estimated)
    if(substring(fileNames[i], 1, 2) == "AQ"){
      lparams <- read.csv(paste0("~/sentinel-detection/data/derived_data/AQ/", 
                                 dir("~/sentinel-detection/data/derived_data/AQ/", 
                                     pattern = as.character(fileID))))
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
    gsfit  <- fitBB(dflist[[i]], varnames = list(ALEAF = "A", GS = "gsw", VPD = "VPDleaf", Ca ="Ca", RH ="RHcham"), 
                    gsmodel = c("BBOpti"), fitg0 = TRUE) 
    g1M     <- summary(gsfit$fit)$parameters[1]				# save g1 from fitted model
    g0M     <- summary(gsfit$fit)$parameters[2]	      # save g0 from fitted model
    g1M_se  <- summary(gsfit$fit)$parameters[1,2]     # save standard error of g1
    g0M_se  <- summary(gsfit$fit)$parameters[2,2]     # save standard error of g0
    
    # Second: fit the Ball-Berry (1987) model    
    gsfit2  <- fitBB(dflist[[i]], varnames = list(ALEAF = "A", GS = "gsw", VPD = "VPDleaf", Ca ="Ca", RH ="RHcham"), 
                     gsmodel = c("BallBerry"), fitg0 = TRUE) 
    g1BB     <- summary(gsfit2$fit)$parameters[1]				
    g0BB     <- summary(gsfit2$fit)$parameters[2]	
    g1BB_se  <- summary(gsfit2$fit)$parameters[1,2] 
    g0BB_se  <- summary(gsfit2$fit)$parameters[2,2]    
    
    # Third: fit the Ball-Berry-Leuning (1995) model    
    gsfit3  <- fitBB(dflist[[i]], varnames = list(ALEAF = "A", GS = "gsw", VPD = "VPDleaf", Ca ="Ca", RH ="RHcham"), 
                     gsmodel = c("BBLeuning"), fitg0 = TRUE, D0 = 1.6) 
    g1L     <- summary(gsfit3$fit)$parameters[1]				
    g0L     <- summary(gsfit3$fit)$parameters[2]	
    g1L_se  <- summary(gsfit3$fit)$parameters[1,2] 
    g0L_se  <- summary(gsfit3$fit)$parameters[2,2] 
    
    # create vector of data for output file (site, species, g1, ci_low, ci_hig)
    temp <- data.frame(ID = rep(fileID, 6),
                       rep = rep(names(dflist)[i], 6),
                       trait = c("g0M", "g1M", "g0BB", "g1BB", "g0L", "g1L"),
                       Value = c(g0M, g1M, g0BB, g1BB, g0L, g1L),
                       SE = c(g0M_se, g1M_se, g0BB_se, g1BB_se, g0L_se, g1L_se),
                       SD = rep(NA, 6),
                       Date.run = rep(as.Date(Sys.time()), 6))
    
    out <- rbind.data.frame(out, temp)
    
  }
  
  # Location of output files
  if(dir.exists("~/sentinel-detection/data/derived_data/stomatal/diagnostic") == F){
    dir.create("~/sentinel-detection/data/derived_data/stomatal/diagnostic", recursive = TRUE)
  }
  loc <- paste0("~/sentinel-detection/data/derived_data/stomatal/")
  write.csv(out, file = paste0(loc, fileID, "_parameters.csv"), row.names = F)
  
  # Plotting 
  # Visualize across 3 replicates
  # create dataframe for plotting
  DF <- data.frame(rep = rep(df$rep, 3),
                   gsw = rep(df$gsw, 3),
                   x = c(df$A*df$RHcham/df$Ca/100, #divide RH/100
                         df$A/(df$CO2_s*sqrt(df$VPDleaf)),
                         df$A/df$Ca/(1+df$VPDleaf/1.6)),
                   type = c(rep("BB", nrow(df)), rep("M", nrow(df)), rep("BBL", nrow(df))))
  params <- data.frame(type = rep(c("M", "BB", "BBL"), 3),
                       rep = rep(names(dflist), each = 3),
                       slope = out$Value[out$trait %in% c("g1BB", "g1M", "g1L")],
                       int = out$Value[out$trait %in% c("g0BB", "g0M", "g0L")])
  
  # Medlyn model is not strictly linear, therefore plotted line does not go through points
  
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
  
  

  