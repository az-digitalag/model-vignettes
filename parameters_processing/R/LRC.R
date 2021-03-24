# Function to run the light response curve with nls

LRC <- function(fileID){# input is ID column from the experiments dataframe
  
  # Read in data
  df <- read.csv(paste0("~/sentinel-detection/data/cleaned_data/AQ/AQin_curves_", fileID, ".csv"))
  
 
  
  # Declare lists and dataframe
  LIS <- split(df, df$rep)   # splitting data into separate elements of list by replicate
  mods <- vector(mode = "list", length = length(LIS))  # empty list to store models
  out <- data.frame()    # empty df to store parameter estimates
  head <- c("Plant 1", "Plant 2", "Plant 3")        

  # Location of output files
  if(dir.exists("~/sentinel-detection/data/derived_data/AQ/diagnostic") == F){
    dir.create("~/sentinel-detection/data/derived_data/AQ/diagnostic", recursive = TRUE)
  }
  loc <- paste0("~/sentinel-detection/data/derived_data/AQ/")
  
  for (i in 1:length(LIS)) {
      PARlrc<-LIS[[i]]$Qin #Qin (aka PPFD or PAR)
      photolrc<-LIS[[i]]$A #net photosynthetic rate (Anet)
      curvelrc<-data.frame(PARlrc,photolrc)

      # Fit the nolinear model
      mods[[i]] <- nls(photolrc ~ (1/(2*theta))*
                         (AQY*PARlrc+Am-sqrt((AQY*PARlrc+Am)^2-4*AQY*theta*Am*PARlrc))
                       -Rd,start=list(Am=(max(photolrc)-min(photolrc)),AQY=0.05,Rd=-min(photolrc),theta=1)) 

   

    # Plot AQ curves
    # Plotting parameters
    heading <- unique(df$rep)       
    plot.new()
    #x11(15,8)
    par(pty="s")
    par(mfrow = c(1, 3))
    par(oma = c(5, 4., 5, 1))
    par(mar=c(4.5, 4.5, 3.5, 2), mgp=c(2.4, 0.8, 0), las=0)
    
    #
    pdf(paste0(loc, "diagnostic/", fileID, "_", heading[i], "_LRC.pdf"))
    plot(PARlrc,photolrc,xlab="", ylab="", ylim=c(-3,30),cex.lab=1.2,cex.axis=1.5,cex=2, main=(head[i]))
    mtext(expression("PPFD ("*mu*"mol "*m^-2*s^-1*")"),side=1,line=3.3,cex=1)
    mtext(expression(A[net]*" ("*mu*"mol "*CO[2]*" "*m^-2*s^-1*")"),side=2,line=2,cex=1)
    curve((1/(2*summary(mods[[i]])$coef[4,1]))*
            (summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1]-
               sqrt((summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1])^2-4*
                      summary(mods[[i]])$coef[2,1]*summary(mods[[i]])$coef[4,1]*
                      summary(mods[[i]])$coef[1,1]*x))-summary(mods[[i]])$coef[3,1],lwd=2,col="blue",add=T)
       dev.off()
    
    
    # ---Solve for light compensation point (LCPT), PPFD where Anet=0 ---
    x<-function(x) {(1/(2*summary(mods[[i]])$coef[4,1]))*
        (summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1]-
           sqrt((summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1])^2-4*
                  summary(mods[[i]])$coef[2,1]*summary(mods[[i]])$coef[4,1]*
                  summary(mods[[i]])$coef[1,1]*x))-summary(mods[[i]])$coef[3,1]}
    
    LCPT <- uniroot(x,c(0,250))$root #LCPT    light compensation point
    
    # ---Solve for light saturation point (LSP), PPFD where 75% of Amax is achieved (75% is arbitrary - cutoff could be changed)
    x<-function(x) {
      (1/(2*summary(mods[[i]])$coef[4,1]))*
        (summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1]
         -sqrt((summary(mods[[i]])$coef[2,1]*x+summary(mods[[i]])$coef[1,1])^2-4*
                 summary(mods[[i]])$coef[2,1]*summary(mods[[i]])$coef[4,1]*
                 summary(mods[[i]])$coef[1,1]*x))-summary(mods[[i]])$coef[3,1]-
        (0.75*summary(mods[[i]])$coef[1,1])+0.75*(summary(mods[[i]])$coef[3,1])}
    
    
    LSP <-  uniroot(x,c(10,2000))$root #LSP 
    
    
    # Getting estimated parametters 
    
    Am         <- summary(mods[[i]])$coef[1,1]     # Maximum assimilation
    Am_se      <- summary(mods[[i]])$coef[1,2]     # p-value of Am
    AQY        <- summary(mods[[i]])$coef[2,1]     #AQY (apparent quantum yield), 
    AQY_se     <- summary(mods[[i]])$coef[2,2]     # p-value of AQY
    Rd         <- summary(mods[[i]])$coef[3,1]     #Rd (dark respiration)
    Rd_se      <- summary(mods[[i]])$coef[3,2]
    theta      <- summary(mods[[i]])$coef[4,1]     #Theta (curvature parameter, dimensionless)
    theta_se   <- summary(mods[[i]])$coef[4,2]
    
    # create vector of data for output file (site, species, g1, ci_low, ci_hig)
    
    params <- data.frame(ID = rep(fileID, 6),
                         rep = unique(LIS[[i]]$rep),
                         trait = c("LCPT", "LSP", "Am", "AQY", "Rd", "theta_lc"),
                         Value = c(LCPT, LSP, Am, AQY, Rd, theta),
                         SE = c(NA, NA, Am_se, AQY_se, Rd_se, theta_se),
                         SD = rep(NA, 6),
                         Date.run = rep(as.Date(Sys.time()), 6))
    
    out <- rbind(out, params)
   
  }
  # Write to file
  write.csv(out, file = paste0(loc, fileID, "_parameters.csv"), row.names = F)
}