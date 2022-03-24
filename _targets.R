# _targets.R file
library(targets)

# Source functions in R folder
lapply(grep("R$", list.files("R"), value = TRUE), function(x) source(file.path("R", x)))

# Set options (i.e. clustermq for multiprocess computing)
options(tidyverse.quiet = TRUE, clustermq.scheduler = "multiprocess")
tar_option_set(packages = c("terra", "rgdal", "dplyr", "data.table",
                            "tidyr", "purrr", "lubridate"))

# List of targets
list(
  
    # Coordinates file
  tar_target(plots_file, "data/data_plots_test.csv", format = "file"),
  tar_target(data_plots, fread(plots_file)),
  tar_target(coords, data_plots %>% select(plotcode, longitude, latitude, altitude)),
  
  
  
  ##############################################################################
  ############################ CLIMATIC DATA ###################################
  ##############################################################################
  
    # Use dynamic branching through years and vars
  tar_target(years, seq(1983,2018)),
  tar_target(vars, c("tas")), # c("pet", "pr", "tas", "tasmin", "tasmax")
  
  
    # Extract chelsa values (produce one file per variable per year with values for all coordinates) and merge them into one file per year with all variables for each month
  tar_target(chelsa_raw_vars_years, Extract_Chelsa_var_year(coords, vars, years, folderpath_chelsa_vars = "../SamsaraEurope_database/data/syno/envicloud/chelsa/chelsa_V2/GLOBAL/monthly"), pattern = cross(vars, years), iteration = "list"),
  tar_target(chelsa_merged_years, Merge_ChelsaVars_year(chelsa_raw_vars_years, years, save_file = FALSE), pattern = map(years), iteration = "list"),
    
  
    # Compute and write (in output folder if rasters are not already computed in folderpath_try_lr) lapserate rasters for each month of each year within the extent of the data (slope of regression of chelsa tas against wc elevation)
  tar_target(months, c(paste0("0", 1:9), 10:12)),
  tar_target(crop_ext, Get_CropExt(coords)),
  tar_target(rast_lr_filepath_years_months, Compute_and_Write_LapseRate_Raster_year_month(years, months, crop_ext, window_size = 11, 
                                                                                          folderpath_tas = "../SamsaraEurope_database/data/syno/envicloud/chelsa/chelsa_V2/GLOBAL/monthly/tas", 
                                                                                          filepath_alt = "../SamsaraEurope_database/data/syno/WorldClim/wc2.1_30s_elev.tif",
                                                                                          folderpath_try_lr = "../SamsaraEurope_database/data/syno/lapserate"), pattern = cross(years, months), iteration = "list"),
  
  
    # Extract and bind worldclim elevation and tas lapserate and then compute corrected chelsa tas (tascorrect) 
  tar_target(data_lr_years, Extract_LapseRate_year(coords, years, rast_lr_filepath_years_months), pattern = map(years), iteration = "list"),
  tar_target(data_alt_wc, Extract_WCalt(coords, filepath_alt = "../SamsaraEurope_database/data/syno/WorldClim/wc2.1_30s_elev.tif")),
  tar_target(chelsa_lr_alts_years, Bind_ChelsaLrAlt_years(chelsa_merged_years, data_lr_years, data_alt_wc, coords[,c("plotcode", "altitude")], years), pattern = map(years), iteration = "list"),
  tar_target(chelsa_corrected_years, Correct_TAS_year(chelsa_lr_alts_years, save_file = TRUE), pattern = map(chelsa_lr_alts_years), iteration = "list"),


    # Rescale chelsa variables for each year
  tar_target(chelsa_rescaled_years, Rescale_Chelsa_year(chelsa_corrected_years, c(vars, "tascorrect"), save_file = FALSE), pattern = map(chelsa_corrected_years), iteration = "list"),


    # Compute new variables (SGDD, wai, wa, vegetative month...) for each year
  tar_target(chelsa_all_years, Compute_Derived_Variables_year(chelsa_rescaled_years, save_file = TRUE), pattern = map(chelsa_rescaled_years), iteration = "list"),


    # Create final climatic dataset (variables for each plot during the increment period)
  tar_target(data_climatic, Compute_Mean_IncrementPeriod(chelsa_all_years, data_plots)),
  tar_target(data_climatic_filepath, Save_Final_Data_Climatic(data_climatic))
)

