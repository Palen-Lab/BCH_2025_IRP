library(terra)
library(sf)

setwd("E:/Github/BC Hydro Project")

# bc boundary
bc <- vect("Admin Boundaries/BC/bc_boundary.shp")

rast_layer <- rast(ext(bc), resolution = 100, crs = crs(bc))
