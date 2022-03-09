Compute_Mean_IncrementPeriod_plot <- function(row_id, chelsa_all, data_plots) {
  
    # Compute variables from first survey year - 2 years to second survey year
  year_range <- seq(lubridate::year(data_plots$surveydate1[row_id])-2,
                    lubridate::year(data_plots$surveydate2[row_id]))
  
    # True if year element in each list is equal to the given years
  keep_data <- sapply(chelsa_all, function(X) X$year %in% year_range)
  
    # Select the corresponding plotcode within each list of years for the increment period
  chelsa_plot_all <- lapply(chelsa_all[keep_data], function(X) X$data[row_id,])
  
    # Bind df of all years into a single one for each year with all vars
  chelsa_plot_all <- unlist(chelsa_plot_all %>% purrr::reduce(dplyr::full_join, "plotcode"))
  
    # Compute mean and sd of given yearly variables for the increment period
  vars <- c("sgdd", "wa.negsum", "wa.sum", "wai.negsum", "wai.sum")
  for (var in vars) {
    chelsa_plot_all[paste0(var, "_mean")] <- mean(chelsa_plot_all[grepl(var, names(chelsa_plot_all))], na.rm = TRUE)
    chelsa_plot_all[paste0(var, "_sd")] <- sd(chelsa_plot_all[grepl(var, names(chelsa_plot_all))], na.rm = TRUE)
  }

    # Keep only yearly computed variables in var
  chelsa_plot <- c(
    chelsa_plot_all[paste0(vars, "_mean")],
    chelsa_plot_all[paste0(vars, "_sd")]
  )
  
  return(chelsa_plot)
}


Compute_Mean_IncrementPeriod <- function(chelsa_all, data_plots) {
    # Compute for all plotcodes
  chelsa_plots <- lapply(1:nrow(data_plots),
                         Compute_Mean_IncrementPeriod_plot, chelsa_all, data_plots)
  
    # Merge data for each plotcode
  chelsa_plots <- do.call("rbind", chelsa_plots)
  
    # Add plotcode column
  chelsa_plots <- data.frame(plotcode = data_plots$plotcode, chelsa_plots)
  
  return(chelsa_plots)
}



