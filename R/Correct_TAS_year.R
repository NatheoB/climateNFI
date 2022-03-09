Correct_TAS_year <- function(chelsa_year, data_plots) {
  
    # Get month as character (e.g. 01 for January)
  months <- c(paste0("0", 1:9), 10:12)
  
    # For each month
  for (month in months) {
      # Compute tas_correct = tas + lr*(alt_plot - alt_wc)
    chelsa_year$data[,paste("tascorrect", month, chelsa_year$year, sep="_")] <-
      chelsa_year$data[,paste("tas", month, chelsa_year$year, sep="_")] + 
      chelsa_year$data[,paste("lr", month, chelsa_year$year, sep="_")]*
      (data_plots$altitude - chelsa_year$data[,"alt_wc"])
  }
  
  return(chelsa_year)
}