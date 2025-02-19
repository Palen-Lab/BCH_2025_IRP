library(terra)

setwd("E:/Github/BC Hydro Project/")

# matrix to assign weights to zonation rasters
reclass_matrix <- matrix(c(
  0, 0.1, 1,   
  0.11, 0.2, 2,  
  0.21, 0.3, 3,
  0.31, 0.4, 4,
  0.41, 0.5, 5,
  0.51, 0.6, 6,
  0.61, 0.7, 7,
  0.71, 0.8, 8,
  0.81, 0.9, 9,
  0.91, 1.0, 10
), ncol = 3, byrow = TRUE)

# terrestrial zonation
zt <- rast("Zonation/400m/Terrestrial/rankmap.tif")
zt_weights <- classify(zt, reclass_matrix) # assigning weights to all raster values
zt_weighted <- zt * zt_weights # multiplying the original zonation raster by the weight values
writeRaster(zt_weighted, "Zonation/400m/Terrestrial/weighted.tif", overwrite = TRUE)


# freshwater zonation
zfw <- rast("Zonation/400m/Freshwater/rankmap.tif")
zfw_weights <- classify(fwt, reclass_matrix) 
zfw_weighted <- zfw * zfw_weights
writeRaster(fwz_weighted, "Zonation/400m/Freshwater/weighted.tif", overwrite = TRUE)
