# ----------------------------------------------------------------------
# Load required libraries
# ----------------------------------------------------------------------
library(PEcAn.all)
library(PEcAn.utils)
library(RCurl)

# # Add function for setting MA treatments
# source("../set_MA_trt.R")
# 
# # Add function for plotting MA by treatment and trait
# source("../plot_MA.R")
# ----------------------------------------------------------------------
# PEcAn Workflow
# ----------------------------------------------------------------------
# Open, read in, and modify settings file for PEcAn run.
settings <- PEcAn.settings::read.settings("ED2/pecan.docker.ed2.xml") 
settings <- PEcAn.settings::prepare.settings(settings, force = FALSE)
PEcAn.settings::write.settings(settings, outputfile = "pecan.CHECKED.xml")
settings <- PEcAn.workflow::do_conversions(settings)

# Query the trait database for data and priors
settings <- PEcAn.workflow::runModule.get.trait.data(settings)

# Run the PEcAn meta.analysis
PEcAn.MA::runModule.run.meta.analysis(settings)

# If treatment specific, set meta.analysis treatments
# set_MA_trt(settings)

# If treatment specific plots desired, plot MA priors vs. posteriors
# plot_MA(settings)

# Write model specific configs
settings <- PEcAn.workflow::runModule.run.write.configs(settings)

# Manual rsync of run folder to HPC, replacing DATE
#rsync '-a' '-q' '--delete' '/data/tests/ed2/run' 'kristinariemer@login.ocelote.hpc.arizona.edu:/groups/dlebauer/ed2_results/pecan_remote/DATE'

# Start ecosystem model runs
ptm <- proc.time()
PEcAn.remote::runModule.start.model.runs(settings, stop.on.error = FALSE)
proc.time() - ptm

# Manual rsync of out folder back to Welsch, replacing DATE
#rsync '-az' '-q' 'kristinariemer@login.ocelote.hpc.arizona.edu:/groups/dlebauer/ed2_results/pecan_remote/DATE/out' '/data/tests/ed2'

# Do results post-processing
for(folder in list.dirs("/data/tests/ed2/out", recursive = FALSE)){
  model2netcdf.ED2(folder, settings$run$site$lat, settings$run$site$lon, settings$run$start.date, 
                   settings$run$end.date, unlist(purrr::map(settings$pfts, 1)))
  
}

# Get results of model runs
runModule.get.results(settings)

# Run ensemble analysis on model output.
runModule.run.ensemble.analysis(settings, TRUE)

# Run sensitivity analysis and variance decomposition on model output
runModule.run.sensitivity.analysis(settings)

print("---------- PEcAn Workflow Complete ----------")
