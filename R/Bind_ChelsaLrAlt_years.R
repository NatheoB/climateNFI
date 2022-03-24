Bind_ChelsaLrAlt_years <- function(chelsa_years, data_lr_years, data_alt_wc, data_alt_exact, year) {
    # Get the chelsa df for the corresponding year
  chelsa_year <- chelsa_years[sapply(chelsa_years, function(X) X$year==year)]
  chelsa_year <- chelsa_year[[1]]$data
  
    # Get the lr df for the corresponding year
  data_lr_year <- data_lr_years[sapply(data_lr_years, function(X) X$year==year)]
  data_lr_year <- data_lr_year[[1]]$data
 
    # Bind the three datasets
  chelsa_lr_alt_year <- chelsa_year %>% 
    inner_join(data_lr_year, by = "plotcode") %>% 
    inner_join(data_alt_wc, by = "plotcode") %>% 
    inner_join(data_alt_exact, by = "plotcode")
  
  return(list(year = year, data = chelsa_lr_alt_year))
}