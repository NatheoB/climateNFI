Load_and_Add_Mask_Coords <- function(coords, mask_filepath = "data/mask"){
    # Import the raster
  m <- terra::rast(file.path(mask_filepath, "chelsa-w5e5v1.0_obsclim_mask_30arcsec_global.nc"))
  
    # Extract and add mask value for given coords
  res <- terra::extract(m, coords[, c("longitude", "latitude")] )
  coords$mask <- res$mask
  
  return(coords)
}