library(ggplot2)
library(sf)
library(terra)

setwd("E:/BCH_2025_IRP/BCH_2025_IRP/") # set this to wherever you clone the github repository to

# read in all project points
projects <- read_sf("BC Hydro Projects/Shapefiles/Point Locations/all_projects_250210.shp")
plot(projects$geometry)

bc <- read_sf("Admin Boundaries/BC/bc_boundary.shp")
plot(bc$geometry)

# Plot
project_plot <- ggplot() +
  geom_sf(data = bc, fill = NA, color = "black", size = 0.5) +  # BC boundary outline
  geom_sf(data = projects, aes(fill = Resource_T), size = 0.8, shape = 21, color = "black", stroke = 0.2) +  # Project points
  scale_colour_manual(values = c("red", "orange", "yellow3", "green", "turquoise", "blue", "purple", "hotpink")) +
  theme_minimal() +
  labs(color = "Resource Type", x = "Longitude", y = "Latitude") +
  theme(legend.position = "right")

ggsave("Graphics/Project Location Map/all_projects_250210.jpg", width = 15, height = 7.5, units = "cm", dpi = 300)
