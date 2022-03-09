Extract_WCalt <- function(coords, path) {
  
    # Get worldclim elevation raster
  rast <- terra::rast(path)
  
    # Extract values from rasters at coordinates in coords dataframe
  res <- terra::extract(rast, coords[, c("longitude", "latitude")])
  
    # Check number of rows
  if(nrow(res) != nrow(coords)) stop("missing plots")
  
    # Bind plotcode and extracted values (vector of altitude of each coord)
  data_alt <- data.frame(plotcode = coords$plotcode, alt_wc = res[,2])
  
  return(data_alt)
}