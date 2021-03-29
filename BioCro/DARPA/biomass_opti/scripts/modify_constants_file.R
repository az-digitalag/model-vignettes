# Use the output of the optimization algorithm to modify the Setaria constants xml 
# in temp_comparison and env_comparison

# Read in xml used for optimization
ref <- XML::xmlToList(XML::xmlParse("~/model-vignettes/BioCro/DARPA/biomass_opti/inputs/ch_config.xml"))
# Load results of optimization
load("~/model-vignettes/BioCro/DARPA/biomass_opti/scripts/opt_results.Rdata")

# Modify the changed parameters for each Pecan setaria.constants.xml
exp <- c("env_comparison", "temp_comparison")
for(e in exp) {
  config <- XML::xmlToList(XML::xmlParse(
    paste0("~/model-vignettes/BioCro/DARPA/", e, "/inputs/setaria.constants.xml")))
  # First, match the tp values
  config$phenoParms[grep("tp", names(config$phenoParms))] <- ref$pft$phenoParms[grep("tp", names(ref$pft$phenoParms))]
  
  # Second, set seneParms starting with leaf senescence just after physiological maturity (2340 gdds)
  # equivalent to 500 less than the default
  config$seneControl[grep("sen", names(config$seneControl))]  <- ref$pft$seneControl[grep("sen", names(ref$pft$seneControl))]
  
  
  # Third, adjust the k Parms as indicated by opt_results
  rhizomevals <- rep(0.0001, 6)
  parms_results <- as.vector(opt_results$optim$bestmem)
  parms_results[1:3] <- round(parms_results[1:3]/sum(parms_results[1:3], rhizomevals[1]), 4)
  parms_results[4:6] <- round(parms_results[4:6]/sum(parms_results[4:6], rhizomevals[2]), 4)
  parms_results[7:9] <- round(parms_results[7:9]/sum(parms_results[7:9], rhizomevals[3]), 4)
  parms_results[10:12] <- round(parms_results[10:12]/sum(parms_results[10:12], rhizomevals[4]), 4)
  parms_results[13:15] <- round(parms_results[13:15]/sum(parms_results[13:15], rhizomevals[5]), 4)
  parms_results[16:19] <- round(parms_results[16:19]/sum(parms_results[16:19], rhizomevals[6]), 4)
  optimalParms <- list(kStem1 = parms_results[1],
                       kLeaf1 = parms_results[2],
                       kRoot1 = parms_results[3],
                       kRhizome1 = rhizomevals[1],
                       
                       kStem2 = parms_results[4],
                       kLeaf2 = parms_results[5],
                       kRoot2 = parms_results[6],
                       kRhizome2 = rhizomevals[2],
                       
                       kStem3 = parms_results[7],
                       kLeaf3 = parms_results[8],
                       kRoot3 = parms_results[9],
                       kRhizome3 = rhizomevals[3],
                       
                       kStem4 = parms_results[10],
                       kLeaf4 = parms_results[11],
                       kRoot4 = parms_results[12],
                       kRhizome4 = rhizomevals[4],
                       
                       kStem5 = parms_results[13],
                       kLeaf5 = parms_results[14],
                       kRoot5 = parms_results[15],
                       kRhizome5 = rhizomevals[5],
                       
                       kStem6 = parms_results[16],
                       kLeaf6 = parms_results[17],
                       kRoot6 = parms_results[18],
                       kRhizome6 = rhizomevals[6],
                       kGrain6 = parms_results[19])
  
  
  config$phenoParms[grep("kLeaf", names(config$phenoParms))] <- optimalParms[grep("kLeaf", names(optimalParms))]
  config$phenoParms[grep("kStem", names(config$phenoParms))] <- optimalParms[grep("kStem", names(optimalParms))]
  config$phenoParms[grep("kRoot", names(config$phenoParms))] <- optimalParms[grep("kRoot", names(optimalParms))]
  config$phenoParms[grep("kRhizome", names(config$phenoParms))] <- optimalParms[grep("kRhizome", names(optimalParms))]
  config$phenoParms["kGrain6"] <- optimalParms[grep("kGrain6", names(optimalParms))]
  
  config.xml <- PEcAn.settings::listToXml(config, "config")
  XML::saveXML(config.xml, file = 
                 paste0("~/model-vignettes/BioCro/DARPA/", e, "/inputs/setaria.constants.xml"), 
               indent = TRUE)
}

# Modify the changed parameters for each BioCro config.xml
gen <- c("ss", "wt")
for(g in gen) {
  config <- XML::xmlToList(XML::xmlParse(
    paste0("~/model-vignettes/BioCro/DARPA/regional_runs_inputs/config_", g, "_original.xml")))
  config$pft$phenoParms[grep("tp", names(config$pft$phenoParms))] <- ref$pft$phenoParms[grep("tp", names(ref$pft$phenoParms))]
  config$pft$seneControl[grep("sen", names(config$pft$seneControl))]  <- ref$pft$seneControl[grep("sen", names(ref$pft$seneControl))]
  
  rhizomevals <- rep(0.0001, 6)
  parms_results <- as.vector(opt_results$optim$bestmem)
  parms_results[1:3] <- round(parms_results[1:3]/sum(parms_results[1:3], rhizomevals[1]), 4)
  parms_results[4:6] <- round(parms_results[4:6]/sum(parms_results[4:6], rhizomevals[2]), 4)
  parms_results[7:9] <- round(parms_results[7:9]/sum(parms_results[7:9], rhizomevals[3]), 4)
  parms_results[10:12] <- round(parms_results[10:12]/sum(parms_results[10:12], rhizomevals[4]), 4)
  parms_results[13:15] <- round(parms_results[13:15]/sum(parms_results[13:15], rhizomevals[5]), 4)
  parms_results[16:19] <- round(parms_results[16:19]/sum(parms_results[16:19], rhizomevals[6]), 4)
  optimalParms <- list(kStem1 = parms_results[1],
                       kLeaf1 = parms_results[2],
                       kRoot1 = parms_results[3],
                       kRhizome1 = rhizomevals[1],
                       
                       kStem2 = parms_results[4],
                       kLeaf2 = parms_results[5],
                       kRoot2 = parms_results[6],
                       kRhizome2 = rhizomevals[2],
                       
                       kStem3 = parms_results[7],
                       kLeaf3 = parms_results[8],
                       kRoot3 = parms_results[9],
                       kRhizome3 = rhizomevals[3],
                       
                       kStem4 = parms_results[10],
                       kLeaf4 = parms_results[11],
                       kRoot4 = parms_results[12],
                       kRhizome4 = rhizomevals[4],
                       
                       kStem5 = parms_results[13],
                       kLeaf5 = parms_results[14],
                       kRoot5 = parms_results[15],
                       kRhizome5 = rhizomevals[5],
                       
                       kStem6 = parms_results[16],
                       kLeaf6 = parms_results[17],
                       kRoot6 = parms_results[18],
                       kRhizome6 = rhizomevals[6],
                       kGrain6 = parms_results[19])
  
  config$pft$phenoParms[grep("kLeaf", names(config$pft$phenoParms))] <- optimalParms[grep("kLeaf", names(optimalParms))]
  config$pft$phenoParms[grep("kStem", names(config$pft$phenoParms))] <- optimalParms[grep("kStem", names(optimalParms))]
  config$pft$phenoParms[grep("kRoot", names(config$pft$phenoParms))] <- optimalParms[grep("kRoot", names(optimalParms))]
  config$pft$phenoParms[grep("kRhizome", names(config$pft$phenoParms))] <- optimalParms[grep("kRhizome", names(optimalParms))]
  config$pft$phenoParms["kGrain6"] <- optimalParms[grep("kGrain6", names(optimalParms))]
  
  config.xml <- PEcAn.settings::listToXml(config, "config")
  XML::saveXML(config.xml, file = 
                 paste0("~/model-vignettes/BioCro/DARPA/regional_runs_inputs/config_", g, ".xml"), 
               indent = TRUE)
}
