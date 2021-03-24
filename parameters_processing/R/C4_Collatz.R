# Function to run the C4_Collatz model in JAGS

C4_Collatz <- function(fileID){# input is ID column from the experiments dataframe
  
  # Required packages
  library(rjags)
  library(dplyr)
  library(tibble)
  
  # Read in data
  dat <- read.csv(paste0("~/sentinel-detection/data/cleaned_data/ACi/A_Ci_curves_", fileID, ".csv"))
  
  # JAGS code
  my.model.jags <- "
  model{
  alpha ~ dlnorm(-3.21,3.7) 	    	## initial slope of photosynthesis light response
  vmax ~ dlnorm(3,3)                ## maximum rubisco capacity
  r ~ dlnorm(-0.2,2.8)              ## leaf respiration
  k ~ dlnorm(11.5, 2.8)             ## initial slope of photosynthetic CO2 response
  tau ~ dgamma(0.1,0.1)

  for(i in 1:n){                ## process model
    al[i] <- alpha*q[i]         ## light limited without covariates
    ac[i] <- k*pi[i]/100000     ## CO2 limited without covariates
    ae[i] <- vmax               ## rubisco limited without covariates
    prean[i] <- min(min(al[i],ac[i]),ae[i])-r
    an[i] ~ dnorm(prean[i],tau) ## likelihood
    pA[i] ~ dnorm(prean[i],tau) ## prediction
    }
  }
  "
  
  # Set initials for 3 chains
  init <- list()
  init[[1]] <- list(r = 0.8, vmax = 50,alpha = 0.03, tau = 10, k = 0.7*100000)
  init[[2]] <- list(r = 1, vmax = 30, alpha = 0.07, tau = 20, k = 0.8*100000)
  init[[3]] <- list(r = 2, vmax = 15,alpha = 0.06, tau = 20, k = 0.2*1000000)
  
  # Fit model
  rep.list = unique(as.character(dat$rep))   
  c4mcmc <- list()
  
  for(s in rep.list){
    sel = which(dat$rep == s)
    an = dat$A[sel]
    pi = dat$Pci[sel]
    q = dat$Qin[sel]
    
    c4 <- jags.model(file = textConnection(my.model.jags), 
                     data = list(an = an, pi = pi, q = q, n = length(an)), 
                     inits = init, 
                     n.chains = 3)
    update(c4, n.iter = 5000)
    c4.out <- coda.samples(model = c4, 
                           variable.names = c("r","vmax","alpha", "k", "prean", "pA"), 
                           n.iter = 100000, 
                           thin = 25)
    c4mcmc[[s]] = c4.out
  }
  
  # Save out diagnostic plots
  if(dir.exists("~/sentinel-detection/data/derived_data/ACi/diagnostic/") == F){
    dir.create("~/sentinel-detection/data/derived_data/ACi/diagnostic/", recursive = TRUE)
  }
  loc <- paste0("~/sentinel-detection/data/derived_data/ACi/diagnostic/")
  
  # Gelman plots
  for(s in rep.list){
    pdf(paste0(loc, fileID, "_", s, "_gelman.pdf"))
    gelman.plot(c4mcmc[[s]])
    dev.off()
  }
  
  # Trace plots
  for(s in rep.list){
    pdf(paste0(loc, fileID, "_", s, "_trace.pdf"))
    plot(as.mcmc.list(c4mcmc[[s]]))
    dev.off()
  }
  
  # Observed vs. fitted
  for(s in rep.list){
    sel1 = which(dat$rep == s)
    an = dat$A[sel1]
    preans = data.frame(summary(c4mcmc[[s]])$statistics) %>% 
      select(Mean) %>% 
      rownames_to_column() %>% 
      filter(grepl("prean", rowname))
    
    pdf(paste0(loc, fileID, "_", s, "_fit.pdf"))
    plot(an, preans$Mean, pch = 19, main = s, xlab = "Measured An (umol m-2 s-1)",
         ylab = "Predicted An (umol m-2 s-1)", cex.main = 1.3, cex.lab = 1.4)
    abline(0, 1, col="dark green", lwd = 3)
    dev.off()
  }

  # Write out posterior stats
  out <- data.frame()
  for(i in 1:length(rep.list)){
    out <- rbind.data.frame(out, data.frame(summary(c4mcmc[[i]])$statistics) %>% 
                            rownames_to_column() %>% 
                            filter(rowname == "vmax"))
  }
  out$id <- rep.list
  colnames(out) <- c("trait", "Value", "SD", "SE.n", "SE.ts", "rep")
  # Assume n = 2 and calculate SE from SD
  out$SE <- out$SD / sqrt(2)
  out$ID <- rep(fileID, nrow(out))
  out$Date.run <- rep(as.Date(Sys.time()), nrow(out))
  out2 <- subset(out, select = c(ID, rep, trait, Value, SE, SD, Date.run))

  write.csv(out2, file = paste0("~/sentinel-detection/data/derived_data/ACi/", fileID, "_parameters.csv"), row.names = F)
}
