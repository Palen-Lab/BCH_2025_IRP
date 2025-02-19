library(terra)
library(tools)

setwd("E:/Github/BCH_2025_IRP/")

# terrestrial zonation pixels
extract_zonation(input_folder = "BC Hydro Projects/Rasters/400m",
                 output_folder = "Zonation/400m/Terrestrial/project_zonation_rasters",
                 z_raster = "Zonation/400m/Terrestrial/weighted.tif")

calculate_raster_sums(raster_folder = "Zonation/400m/Terrestrial/project_zonation_rasters",
                      output_csv = "E:/Github/BCH_2025_IRP/Zonation/400m/Terrestrial/ter_project_zonation_scores.csv")

# freshwater zonation pixels
extract_zonation(input_folder = "BC Hydro Projects/Rasters/400m",
                 output_folder = "Zonation/400m/Freshwater/project_zonation_rasters",
                 z_raster = "Zonation/400m/Freshwater/weighted.tif")

calculate_raster_sums(raster_folder = "Zonation/400m/Freshwater/project_zonation_rasters",
                      output_csv = "Zonation/400m/Freshwater/fw_project_zonation_scores.csv")

# bind the freshwater and terrestrial zonation scores together
ter <- read.csv("E:/Github/BCH_2025_IRP/Zonation/400m/Terrestrial/ter_project_zonation_scores.csv")
fw <- read.csv("E:/Github/BCH_2025_IRP/Zonation/400m/Freshwater/fw_project_zonation_scores.csv")

all <- full_join(ter, fw, by = "File")
write.csv(all, "Zonation/400m/project_zonation_scores.csv")
