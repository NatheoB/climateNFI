Save_Final_Data_Climatic <- function(data_climatic) {
  filepath <- file.path("output", "data_climatic.csv")
  write.table(data_climatic, filepath, 
              sep=";", dec = ".", row.names = FALSE)
  
  return(filepath)
}