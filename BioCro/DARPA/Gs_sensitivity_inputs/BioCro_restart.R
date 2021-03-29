# Function to start and stop BioCro with different parameteters
BioCro_restart <- function(met,
                           config,
                           duration = 10,
                           start_day = 100,
                           end_day = start_day * 2,
                           prop = 0.1){
  require(BioCro)

  # First round of growth 
  res <- BioCro::BioGro(met, day1 = 1, dayn = start_day,
                        iRhizome = config$pft$iPlantControl$iRhizome,
                        iLeaf = config$pft$iPlantControl$iLeaf,
                        iStem = config$pft$iPlantControl$iStem,
                        iRoot = config$pft$iPlantControl$iRoot,
                        soilControl = l2n(config$pft$soilControl),
                        canopyControl = l2n(config$pft$canopyControl),
                        phenoControl = l2n(config$pft$phenoParms),
                        seneControl = l2n(config$pft$seneControl),
                        photoControl = l2n(config$pft$photoParms))
  
  # Record last iteration of biomass in each organ
  iRhizome <- last(res$Rhizome)
  iRoot <- last(res$Root)
  iStem <- last(res$Stem)
  iLeaf <- last(res$Leaf)
  
  # If duration is set to zero, change to one and increase prop to 1
  if(duration == 0) {
    duration <- 1
    prop <- 1
  }
  
  # Reduce stomatal parameters by prop
  photoP <- l2n(config$pft$photoParms)
  photoP$b0 <- photoP$b0 * prop
  photoP$b1 <- photoP$b1 * prop
  
  # Second round of growth
  res2 <- BioCro::BioGro(met, day1 = start_day + 1, dayn = start_day + duration,
                         iRhizome = iRhizome,
                         iStem = iStem,
                         iLeaf = iLeaf,
                         iRoot = iRoot,
                         soilControl = l2n(config$pft$soilControl),
                         canopyControl = l2n(config$pft$canopyControl),
                         phenoControl = l2n(config$pft$phenoParms),
                         seneControl = l2n(config$pft$seneControl),
                         photoControl = photoP)
  
  # Record last iteration of biomass in each organ
  iRhizome <- last(res2$Rhizome)
  iRoot <- last(res2$Root)
  iStem <- last(res2$Stem)
  iLeaf <- last(res2$Leaf)
  
  # Third round of growth
  res3 <- BioCro::BioGro(met, day1 = start_day + duration + 1, dayn = end_day,
                         iRhizome = iRhizome,
                         iStem = iStem,
                         iLeaf = iLeaf,
                         iRoot = iRoot,
                         soilControl = l2n(config$pft$soilControl),
                         canopyControl = l2n(config$pft$canopyControl),
                         phenoControl = l2n(config$pft$phenoParms),
                         seneControl = l2n(config$pft$seneControl),
                         photoControl = l2n(config$pft$photoParms))
  
  # Remove first element of res2 and res3; these are repeated as initial values
  res2 <- lapply(res2, rem1)
  res3 <- lapply(res3, rem1)
  
  # Combine output
  out <- Map(c, Map(c, res, res2), res3)
  
  return(out)
}

# Function to obtain last element of vector
last <- function(x) {tail(x,1)}

# Function to convert list to numeric
l2n <- function(x) {lapply(x, as.numeric)}

# Function to remove first element of vector
rem1 <- function(x) {x[-1]}
