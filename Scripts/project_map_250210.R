library(ggplot2)
library(sf)
library(terra)

setwd("E:/Github/BC Hydro Project/") # set this to wherever you clone the github repository to

# read in all project points
projects <- read_sf("E:/E2O/bch_projects/BCH_PROJECTS_FINAL/Point_Locations/all_bch_projects.shp")
plot(projects$geometry)

bc <- read_sf("Admin Boundaries/BC/bc_boundary.shp")
plot(bc$geometry)

# merge all major transmission lines into one file
# Set the folder path
shp_folder <- "BC Hydro Projects/Shapefiles/Project/Major Transmission"

# List all shapefiles
shp_files <- list.files(shp_folder, pattern = ".shp", full.names = TRUE)

# Read and merge shapefiles
shp_list <- lapply(shp_files, vect)
all_tx <- do.call(rbind, shp_list)

# Save the merged shapefile
writeVector(all_tx, "BC Hydro Projects/Shapefiles/Project Map/all_tx.shp", overwrite = TRUE)

# bring in tx as a sf
all_tx <- read_sf("BC Hydro Projects/Shapefiles/Project Map/all_tx.shp")

# merge all t1r1 lines into one file
# Set the two main folder paths
folders <- c("E:/E2O/bch_projects/BCH_PROJECTS_FINAL/R1 - Copy", "E:/E2O/bch_projects/BCH_PROJECTS_FINAL/T1 - Copy")

# Get all shapefiles from both folders (including subfolders)
shp_files <- unlist(lapply(folders, function(folder) {
  list.files(folder, pattern = ".shp", full.names = TRUE, recursive = TRUE)
}))

# Read and merge shapefiles
shp_list <- lapply(shp_files, vect)
all_t1r1 <- do.call(rbind, shp_list)

# Save the merged shapefile
writeVector(all_t1r1, "BC Hydro Projects/Shapefiles/Project Map/all_t1r1_old.shp", overwrite = TRUE)

# bring in t1r1 as sf object
all_t1r1 <- read_sf("BC Hydro Projects/Shapefiles/Project Map/all_t1r1_old.shp")

# Plot
project_plot <- ggplot() +
  geom_sf(data = bc, fill = "grey", color = NA) +  # BC boundary outline
  geom_sf(data = all_tx, aes(color = "Major Transmission Lines"), linewidth = 0.2) +  # Make skinnier and add to legend
  geom_sf(data = all_t1r1, aes(color = "Project Roads and Transmission Lines"), linewidth = 0.1) +  # Make skinnier and add to legend
  geom_sf(data = projects, aes(fill = Resource_T), size = 0.8, shape = 21, color = "black", stroke = 0.1) +  # Project points
  scale_color_manual(values = c("Major Transmission Lines" = "brown", "Project Roads and Transmission Lines" = "yellow4")) +  # Define colors for legend
  theme_void() +
  labs(color = "Lines", fill = "Resource Type", x = "Longitude", y = "Latitude") +  # Add legend title
  theme(
    legend.position.inside = c(0.85, 0.85),  # Moves legend closer to the map in the upper right
    legend.justification = c(1, 1),  # Aligns legend properly
    legend.key.size = unit(0.4, "cm"),  # Makes legend symbols smaller
    legend.text = element_text(size = 7),  # Adjusts legend text size
    legend.margin = margin(0, 0, 0, 0)  # Reduces extra spacing around the legend
  ) +
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Increase point size in legend

ggsave("Graphics/Project Location Map/all_projects_250223_old.jpg", width = 7, height = 5, units = "in", dpi = 300)
