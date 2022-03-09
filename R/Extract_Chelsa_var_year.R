Read_Chelsa_Stack_var_year <- function(var, year, path){

  if(!var %in% c("pr", "pet", "tas", "tasmax", "tasmin")) stop("not good var")
  
  xstring <- paste('_',var, '_', sep='')
  files   <- list.files( file.path(path, var), full.names = F)
  ms <- c(paste0("0",1:9), 10:12)
  
  var_file <- ifelse(var == "pet", "pet_penman", var)
  files_sel <- paste0("CHELSA_", var_file, "_",ms,"_",year, "_V.2.1.tif")
  if(sum(!files_sel %in% files)) stop("error missing files")
  layer_t <- terra::rast(file.path(path, var,files_sel[1]))
  layers <- layer_t
  for (m in 2:12){
    layer_t <- terra::rast(file.path(path, var,files_sel[m]))
    add(layers) <- layer_t
  }
  names(layers) <- gsub("_V.2.1", "", gsub("CHELSA_", "", names(layers)))
  return(layers)
}


Extract_Chelsa_var_year <- function(coords, var, year,
                                    path = "data/envicloud/chelsa/chelsa_V2/GLOBAL/monthly") {
  
    # Get rasters for the given variable and year
  stacks <- Read_Chelsa_Stack_var_year(var, year, path)
  
    # Extract values from rasters at coordinates in coords dataframe
  res <- terra::extract(stacks, coords[, c("longitude", "latitude")])
  
    # Check number of rows
  if(nrow(res) != nrow(coords)) stop("missing plots")
  
    # Bind plotcode and extracted values
  res <- cbind(plotcode = coords$plotcode, res %>% select(-ID))
  
  return(list(var = var, year = year, data = res))
}