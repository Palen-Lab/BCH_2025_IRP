library(terra)
library(tools)

setwd("E:/Github/BC Hydro Project/")

# function to extract zonation pixels of each project
extract_zonation <- function(input_folder, output_folder, z_raster) {
  # Load the reference zonation raster
  z_raster <- rast(z_raster)
  
  # Get the list of project folders
  project_folders <- list.dirs(input_folder, recursive = TRUE)
  
  for (folder in project_folders) {
    raster_files <- list.files(folder, pattern = ".tif", full.names = TRUE)
    
    for (raster_file in raster_files) {
      project <- rast(raster_file)
      project[project == 0] <- NA
      
      # Resample zonation raster to match project raster
      zonation_aligned <- resample(z_raster, project, method = "near")
      
      # Mask the resampled raster with the project raster
      project_masked <- mask(zonation_aligned, project, maskvalue = NA, updatevalue = NA)
      
      # Define output path
      output_path <- file.path(output_folder, paste0(file_path_sans_ext(basename(raster_file)), ".tif"))
      
      # Write the raster
      writeRaster(project_masked, filename = output_path, overwrite = TRUE)
    }
  }
}

# function to sum up all zonation pixel values of projects and save to a csv
calculate_raster_sums <- function(raster_folder, output_csv) {
  # List all raster files in the folder
  raster_files <- list.files(raster_folder, pattern = ".tif", full.names = TRUE)
  
  # Initialize an empty data frame to store results
  raster_sums <- data.frame(File = character(), PixelSum = numeric(), stringsAsFactors = FALSE)
  
  # Loop through each raster and calculate the sum of pixel values
  for (raster_file in raster_files) {
    tryCatch({
      # Load the raster
      raster <- rast(raster_file)
      
      # Calculate the sum of pixel values, ignoring NA values
      pixel_sum <- global(raster, fun = "sum", na.rm = TRUE)[1]
      
      # Append the result to the data frame
      raster_sums <- rbind(raster_sums, data.frame(File = basename(raster_file), PixelSum = pixel_sum))
    }, error = function(e) {
      message(paste("Error with file:", raster_file))
    })
  }
  
  # Save the data frame to a CSV file
  write.csv(raster_sums, output_csv, row.names = FALSE)
  
  message(paste("Results saved to", output_csv))
}
