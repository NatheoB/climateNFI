
# climateNFI
A R targets project to compute climatic variables of National Forest inventories' plot

# What it does ?
  - Extract chelsa data for given coords
  - Regress chelsa tas rasters vs worldclim altitude and compute tas_correct (using the computed lapse rate) (DO NOT COMPUTE IF THERE IS ALREADY AN EXISTANT LR RASTER IN THE OUTPUT FILE THAT CAN CONTAINS THE RANGE OF THE DATA_PLOTS COORDINATES)
  - Rescale variables
  - Create derived monthly and yearly variables (SGDD, water availability wa, water availability index wai, vegetative month)
  - Create final climatic dataset with mean of climatic variables over increment period of each plot

# Data needed
Chelsa monthly rasters (one file per variable)
cf : https://envicloud.wsl.ch/#/?prefix=chelsa%2Fchelsa_V2%2FGLOBAL%2Fmonthly%2F

# Inputs
A file with following columns
- plotcode (character)
- longitude (numeric)
- latitude (numeric)
- altitude (numeric) (can be NA)
- surveydate1 (Date)
- surveydate2 (Date)

# Outputs
- data_climatic.csv (file with mean of climatic variables over increment period of each plot)
- lr_month_year.tif (raster of lapse rate for a given month and year)
- data_climatic_year.csv (OPTIONAL) (file with raw and derived variables for the given year)

# How to run ?
- tar_make() ==> run the script with one thread
- tar_make_clustermq(workers = N) ==> run the script with N threads in parallel 

# Contact
natheo.beauchamp@inrae.fr
beauchamp.natheo@gmail.com
Nathéo Beauchamp
