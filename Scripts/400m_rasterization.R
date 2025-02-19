library(terra)
library(dplyr)

setwd("E:/Github/BCH_2025_IRP/")

#### TEST ####

# test out rasterization with one project
atg <- vect("BC Hydro Projects/Shapefiles/Project/Biomass/WBBio_LM_RR.shp")
atg_rast_layer <- rast(ext(atg), res = 400, crs = crs(atg))
atg_rast <- rasterize(atg, atg_rast_layer)
plot(atg_rast)

r1 <- vect("BC Hydro Projects/Shapefiles/R1/Biomass/WBBio_LM_RR_R1.shp")
r1_rast_layer <- rast(ext(r1), res = 400, crs = crs(r1))
r1_buff <- buffer(r1, width = 200) # so that it has an extent enough for rasterization
r1_rast_layer <- rast(ext(r1_buff), res = 400, crs = crs(r1))

extent_r1 <- ext(r1)

# Try to create the raster with the given extent
r1_rast_layer <- tryCatch({
  rast(ext(r1), res = 400, crs = crs(r1))  # Attempt to create raster
}, error = function(e) {
  # If there is an error (invalid extent), buffer the r1 object by 200 meters and create the raster
  r1_buffered <- buffer(r1, width = 200)
  rast(ext(r1_buffered), res = 400, crs = crs(r1))
})


r1_rast <- rasterize(r1, r1_rast_layer)
plot(r1_rast)

t1 <- vect("BC Hydro Projects/Shapefiles/T1/Biomass/WBBio_LM_RR_T1.shp")
t1_rast_layer <- rast(ext(t1), res = 400, crs = crs(t1))
t1_rast <- rasterize(t1, t1_rast_layer)
plot(t1_rast)

collection <- sprc(atg_rast, r1_rast, t1_rast)
project <- merge(collection)
plot(project)

# test function (in 400m_rasterization_functions.R)

functiontest1 <- rasterize_projects(atg_shp = "BC Hydro Projects/Shapefiles/Project/Biomass/WBBio_LM_RR.shp",
                                    r1_shp = "BC Hydro Projects/Shapefiles/R1/Biomass/WBBio_LM_RR_R1.shp",
                                    t1_shp = "BC Hydro Projects/Shapefiles/T1/Biomass/WBBio_LM_RR_T1.shp")
plot(functiontest1)

#### RASTERIZING NORMAL PROJECTS ####
# normal meaning there is one atg shp

# rasterize battery
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Battery",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Battery",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Battery",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Battery/")

# rasterize biomass
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Biomass",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Biomass",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Biomass",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Biomass/")

# rasterize geothermal
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Geothermal",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Geothermal",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Geothermal",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Geothermal/")

# rasterize run of river
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Run of River",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Run of River",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Run of River",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Run of River/")

# rasterize small storage hydro
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Small Storage Hydro",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Small Storage Hydro",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Small Storage Hydro",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Small Storage Hydro/")

# rasterize solar
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Solar",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Solar",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Solar",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Solar/")

# rasterize wind ridge
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Wind/Ridgelines",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Wind",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Wind",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Wind/")

# rasterize wind plateau with example point locations (only for visualization purposes)
rasterize_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Wind/All Wind",
                 r1_folder = "BC Hydro Projects/Shapefiles/R1/Wind",
                 t1_folder = "BC Hydro Projects/Shapefiles/T1/Wind",
                 output_dir = "BC Hydro Projects/Rasters/400 m/Wind/All Wind (Plateau with points)/")


#### EXCEPTION RASTERIZATIONS ####
# remaining projects are little funky so need their own functions

rasterize_pump_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Pump Storage",
                      r1_folder = "BC Hydro Projects/Shapefiles/R1/Pump Storage",
                      t1_folder = "BC Hydro Projects/Shapefiles/T1/Pump Storage",
                      output_dir = "BC Hydro Projects/Rasters/400 m/Pump Storage/")

# plateau wind sites only need r1t1 to be joined together as zonation values will be extracted from bootstrapping
# plateau wind for EF extraction (only t1r1)
rasterize_t1r1_folder(project_folder = "BC Hydro Projects/Shapefiles/Project/Wind/Plateau Points",
               r1_folder = "BC Hydro Projects/Shapefiles/R1/Wind",
               t1_folder = "BC Hydro Projects/Shapefiles/T1/Wind",
               output_dir = "BC Hydro Projects/Rasters/400 m/Wind/")


