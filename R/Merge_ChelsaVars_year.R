Merge_ChelsaVars_year <- function(chelsa_vars_years, year, save_files) {
  
    # True if year element in each list is equal to the given year
  keep_data <- sapply(chelsa_vars_years, function(X) X$year == year)
  
    # Select dataframe from lists of the given year
  chelsa_year_merged <- lapply(chelsa_vars_years[keep_data], function(X) X$data)
  
    # Bind df for all vars and all years into a single one for each year with all vars
  chelsa_year_merged <- chelsa_year_merged %>% purrr::reduce(full_join, by = "plotcode")
  
    
    # Save the file
  if (save_files) {
    write.table(chelsa_year_merged, file.path("output", paste0("data_climatic_raw_", year, ".csv")),
                row.names = FALSE, sep = ";", dec = ".")
  }
  
  
    # Return result as a list
  return(list(year = year, data = chelsa_year_merged))
}