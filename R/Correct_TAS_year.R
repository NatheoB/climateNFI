Correct_TAS_year <- function(chelsa_year, save_files) {
  
    # Get month as character (e.g. 01 for January)
  months <- c(paste0("0", 1:9), 10:12)
  
    # For each month
  for (month in months) {
    
    colname <- paste("tascorrect", month, chelsa_year$year, sep="_")  
    
      # Compute tas_correct = tas + lr*(alt_plot - alt_wc)
    chelsa_year$data[,colname] <-
      chelsa_year$data[,paste("tas", month, chelsa_year$year, sep="_")] + 
      chelsa_year$data[,paste("lr", month, chelsa_year$year, sep="_")]*
      (chelsa_year$data[,"altitude"] - chelsa_year$data[,"alt_wc"])
    
      # tas_correct is NA <==> data_plots$altitude is NA (no altitude on the provided NFI) : set it to tas
    chelsa_year$data[is.na(chelsa_year$data[,colname]), colname] <- 
      chelsa_year$data[is.na(chelsa_year$data[,colname]), paste("tas", month, chelsa_year$year, sep="_")]
  }
  
    # Save the file
  if (save_files) {
    write.table(chelsa_year$data, file.path("output", paste0("data_climatic_corrected_", chelsa_year$year, ".csv")),
                row.names = FALSE, sep = ";", dec = ".")
  }
  
  return(chelsa_year)
}