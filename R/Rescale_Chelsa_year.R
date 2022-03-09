rescale_coef_list <- list(
  "pet"         = c(scale = 1,      offset = 0),       # In kg.m-2
  "pr"          = c(scale = 0.01,   offset = 0),       # In kg.m-2
  "tas"         = c(scale = 0.1,    offset = -273.15), # In Degree Celsius
  "tasmin"      = c(scale = 0.1,    offset = -273.15), # In Degree Celsius
  "tasmax"      = c(scale = 0.1,    offset = -273.15), # In Degree Celsius
  "tascorrect" = c(scale = 0.1,    offset = -273.15)  # In Degree Celsius
)

Rescale_Chelsa_year <- function(chelsa_year, vars) {
    # Params list
  if(length(setdiff(vars, names(rescale_coef_list))) > 0) {stop("missing scale coeffs")}
  
    # Rescale each variable
  for (var in vars) {
      # Get rescale coefs from the list above
    rescale_coef <- rescale_coef_list[[var]]
    
      # Rescale considered columns
    chelsa_year$data <- chelsa_year$data %>%
      mutate_at(vars(contains(paste0(var, "_"))), 
                ~ round(rescale_coef[["scale"]]*.+rescale_coef[["offset"]], digits = 5))
  }
  
  return(chelsa_year)
}