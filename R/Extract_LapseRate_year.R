Load_Raster_year_month <- function(rast_lr_years_months_filepath, year, month) {
    # Get raster filepath of given year and month
  rast_list <- rast_lr_years_months_filepath[sapply(rast_lr_years_months_filepath, function(X) X$year==year & X$month==month)]
  
    # BE CAREFUL, rast_list still be a list of list, even if there is one element (i.e. the corresponding month and year)
    # Thus, take the first list (i.e. the corresponding one before extracting path)
  return(terra::rast(rast_list[[1]]$path))
}


Read_LapseRate_Stack_year <- function(year, rast_lr_years_months_filepath) {

    # Create months vector
  months_without_01 <- c(paste0("0",2:9), 10:12)
  
    # Import raster for each month and add it to the raster stack for the given year
  layers.tmp <- Load_Raster_year_month(rast_lr_years_months_filepath, year, "01")
  layers <- layers.tmp
  for (m in months_without_01) {
    layers.tmp <- Load_Raster_year_month(rast_lr_years_months_filepath, year, m) 
    add(layers) <- layers.tmp
  }
  
  return(layers)
}


Extract_LapseRate_year <- function(coords, year, rast_lr_years_months_filepath) {
  
    # Get lapserate rasters for each month as a stack for the given year
  stacks <- Read_LapseRate_Stack_year(year, rast_lr_years_months_filepath)
  
    # Extract values from rasters at coordinates in coords dataframe
  res <- terra::extract(stacks, coords[, c("longitude", "latitude")])
  
    # Check number of rows
  if(nrow(res) != nrow(coords)) stop("missing plots")
  
    # Bind plotcode and extracted values
  data_lr <- cbind(plotcode = coords$plotcode, res %>% select(-ID))
  
  return(list(year = year, data = data_lr))
}