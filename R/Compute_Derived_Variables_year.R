Compute_SGDD_monthly_weightedsum <- function(tas_months, year, sgdd_threshold = 5.5) {
  
    # Get number of days in each month of given year (my)
  mys <- paste0(c(paste0("0", 1:9), 10:12), "_", year) 
  days <- lubridate::days_in_month(lubridate::my(mys))
  
    # Substract sgdd threshold to all tas values
  tas_months <- tas_months - sgdd_threshold
  
    # Set tas to 0 if tas < sgdd threshold
  tas_months[tas_months<0] <- 0
  
    # Weighted Sum of all columns
  return(sum(tas_months*days))
} 


Compute_Derived_Variables_year <- function(chelsa_year, save_files = FALSE) {
  ### Compute monthly variables :  wai, wa and veget_period
  
    # Get month as character (e.g. 01 for January)
  months <- c(paste0("0", 1:9), 10:12)
  
    # For each month
  for (month in months) {
      
      # Compute wa = Pr - PET
    chelsa_year$data[,paste("wa", month, chelsa_year$year, sep="_")] <-
      chelsa_year$data[,paste("pr", month, chelsa_year$year, sep="_")] - 
      chelsa_year$data[,paste("pet_penman", month, chelsa_year$year, sep="_")]
    
      # Compute wai = (Pr - PET)/PET
    chelsa_year$data[,paste("wai", month, chelsa_year$year, sep="_")] <-
      (chelsa_year$data[,paste("pr", month, chelsa_year$year, sep="_")] - 
         chelsa_year$data[,paste("pet_penman", month, chelsa_year$year, sep="_")])/
      chelsa_year$data[,paste("pet_penman", month, chelsa_year$year, sep="_")]
    
      # Compute veget_period : TRUE if tas > 5.5 and wai > 0
    chelsa_year$data[,paste("veget_period", month, chelsa_year$year, sep="_")] <-
      chelsa_year$data[,paste("wai", month, chelsa_year$year, sep="_")] > 0 &
      chelsa_year$data[,paste("tas", month, chelsa_year$year, sep="_")] > 5.5
  }
  
  
  ### Compute yearly variables : sgdd, wa.sum, wa.negsum, wai.mean, wa.mean, wai.sd, wa.sd
  
    # Compute sgdd : sum of growing degree days above a 5.5°C threshold
  chelsa_year$data[,paste0("sgdd_", chelsa_year$year)] <- apply(as.matrix(select(chelsa_year$data, contains("tascorrect_"))),
                                                                1, Compute_SGDD_monthly_weightedsum, year = chelsa_year$year)
  
    # Compute (negative) sum of water availability wa and (negative) sum of water availability index wai
  for (var in c("wa", "wai")) {
      # Temp matrix for a given var
    tmp <- as.matrix(chelsa_year$data %>% select(contains(paste0(var,"_"))))
    
      # wai.sum and wa.sum = sum of water availability (index) over the whole year
    chelsa_year$data[,paste0(var, ".sum_", chelsa_year$year)] <- apply(tmp, 1, sum)
    
      # wai.negsum and wa.negsum = sum of negative values of water availability (index) over the whole year (stress conditions)
    tmp[tmp>0] <- 0 #set positive number to 0 
    chelsa_year$data[,paste0(var, ".negsum_" ,chelsa_year$year)] <- apply(abs(tmp), 1, sum)
  }
  
  
    # Compute mean and std for all given vars
  for (var in c("pr", "pet", "wa", "wai", "tas", "tasmin", "tasmax", "tascorrect")) {
      # Temp matrix for a given var
    tmp <- as.matrix(chelsa_year$data %>% select(contains(paste0(var,"_"))))
    
      # Mean
    chelsa_year$data[,paste0(var, ".mean_", chelsa_year$year)] <- apply(tmp, 1, mean)
    
      # Standard deviation
    chelsa_year$data[,paste0(var, ".sd_" ,chelsa_year$year)] <- apply(tmp, 1, sd)
  }
  
  
    # Save the file
  if (save_files) {
    write.table(chelsa_year$data, file.path("output", paste0("data_climatic_", chelsa_year$year, ".csv")),
                row.names = FALSE, sep = ";", dec = ".")
  }
  
  return(chelsa_year)
}
