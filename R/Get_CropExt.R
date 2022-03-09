Get_CropExt <- function(coords) {
  long_min <- floor(min(coords$longitude))
  long_max <- ceiling(max(coords$longitude))
  lat_min  <- floor(min(coords$latitude))
  lat_max  <- ceiling(max(coords$latitude))
  
  return(c(long_min, long_max, lat_min, lat_max))
}