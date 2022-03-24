Compute_and_Write_LapseRate_Raster_year_month <- function(year, month, crop_ext, window_size,
                                                          folderpath_tas, filepath_alt,
                                                          folderpath_try_lr) {
    
  rast_lr_filename <- paste0("lr_", month, "_", year, ".tif")

  # Do not compute the raster if it exists in the try_lr folder and it contains the crop extent
  if (rast_lr_filename %in% list.files(folderpath_try_lr)) {
      # Load the lapse rate raster
    rast_lr <- terra::rast(file.path(folderpath_try_lr, rast_lr_filename))
      
      # Do not recompute if the crop extent is contained or equals within the output raster
    rast_lr_ext <- terra::ext(rast_lr)
    if (crop_ext[1] >= rast_lr_ext[1] | # X : Crop min >= output min
        crop_ext[2] <= rast_lr_ext[2] | # X : Crop max <= output max
        crop_ext[3] >= rast_lr_ext[3] | # Y : Crop min >= output min
        crop_ext[4] <= rast_lr_ext[4])  # Y : Crop max <= output max
    {
      return(list(year = year, month = month, path = file.path(folderpath_try_lr, rast_lr_filename)))
    }
  }
  
  # Else, compute and save the lapserate raster in output folder

    # Load the climate raster
  rast_tas_filename <- paste("CHELSA_tas", month, year, "V.2.1.tif", sep="_")
  if (!rast_tas_filename %in% list.files(folderpath_tas)) {stop("tas raster not in folder")}
  rast_tas <- terra::rast(file.path(folderpath_tas, rast_tas_filename))
  
    # Load the altitude raster
  rast_altitude <- terra::rast(filepath_alt)
  
    # Crop rasters
  rast_altitude <- terra::crop(rast_altitude, crop_ext)
  rast_tas <- terra::crop(rast_tas, crop_ext)
  
    # Combine the two layers, temperature first 
  x <- c(rast_tas, rast_altitude)
  
    # Do regression - we are interested in the second layer, which represents the lapse rate
  lapse_reg <- focalRegBR(x, w = window_size, na.rm = TRUE)
  lapse_reg <- lapse_reg["B1"]
  
    # Rename the raster as lr_01_1983
  names(lapse_reg) <- paste("lr", month, year, sep="_")
  
    # Write lapse_rate raster
  output_path <- file.path("output", rast_lr_filename)
  terra::writeRaster(lapse_reg, output_path, overwrite = TRUE)
  
  return(list(year = year, month = month, path = file.path(output_path, rast_lr_filename)))
}


### Script from Dr. Bjorn Reineking
#' Adapted from focalReg, and modified so as to return NA for slope and intercept if there are too few observations to fit a regression
focalRegBR <- function (x, ...) 
{
  .local <- function (x, w = 3, na.rm = TRUE, fillvalue = NA, 
                      filename = "", ...) 
  {
    ols_narm <- function(x, y) {
      v <- na.omit(cbind(y, x))
      if (NROW(v) < (NCOL(x) + 1)) {
        return(matrix(NA, ncol = 1, nrow = 2))
      }
      X <- cbind(1, v[, -1])
      XtX <- t(X) %*% X
      # If det(XtX) == 0 (exactly singular, thus non invertible)
      if (det(XtX) == 0) {
        return(matrix(NA, ncol = 1, nrow = 2))
      }
      # or very close to 0 (R considers the matrix as computationally singular, thus non invertible)
      invXtX <- tryCatch(
        expr = {solve(XtX) %*% t(X)},
        error = function(e){
          if (grepl("system is computationally singular", e$message)) {
            return(NULL)
          } else {
            error("focalReg2", e$message)
          }
        })
      if (is.null(invXtX)) {
        return(matrix(NA, ncol = 1, nrow = 2))
      }
      invXtX %*% v[, 1]
    }
    nl <- nlyr(x)
    if (nl != 2) 
      error("focalReg2", "x must have 2 layers")
    if (!is.numeric(w)) {
      error("focalReg", "w should be numeric vector or matrix")
    }
    if (is.matrix(w)) {
      m <- as.vector(t(w))
      w <- dim(w)
    }
    else {
      w <- rep_len(w, 2)
      stopifnot(all(w > 0))
      m <- rep(1, prod(w))
    }
    msz <- prod(w)
    dow <- !isTRUE(all(m == 1))
    isnam <- FALSE
    if (any(is.na(m))) {
      k <- !is.na(m)
      mm <- m[k]
      msz <- sum(k)
      isnam <- TRUE
    }
    out <- rast(x)
    if (na.rm) {
      fun = function(x, y) {
        ols_narm(x, y)
      }
    }
    else {
      error("focalReg2", "na.rm must be TRUE")
    }
    names(out) <- paste0("B", 0:(nl - 1))
    b <- writeStart(out, filename, n = msz * 4, ...)
    ry <- x[[1]]
    rx <- x[[-1]]
    if (nl == 2) {
      for (i in 1:b$n) {
        Y <- focalValues(ry, w, b$row[i], b$nrows[i], 
                         fillvalue)
        X <- focalValues(rx, w, b$row[i], b$nrows[i], 
                         fillvalue)
        if (dow) {
          if (isnam) {
            Y <- Y[k] * mm
            X <- X[k] * mm
          }
          else {
            Y <- Y * m
            X <- X * m
          }
        }
        v <- t(sapply(1:nrow(Y), function(i) fun(X[i, 
        ], Y[i, ])))
        writeValues(out, v, b$row[i], b$nrows[i])
      }
    }
    out <- writeStop(out)
    return(out)
  }
  .local(x, ...)
}