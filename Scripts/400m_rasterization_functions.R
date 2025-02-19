library(terra)
library(dplyr)

setwd("E:/Github/BC Hydro Project/")

# Create function to rasterize project ####
rasterize_projects <- function(atg_shp, r1_shp, t1_shp) {
  
  # Read ATG
  atg <- vect(atg_shp) 
  atg_rast_layer <- tryCatch({
    rast(ext(atg), res = 400, crs = crs(atg)) 
  }, error = function(e) {
    atg_buff <- buffer(atg, width = 200)
    rast(ext(atg_buff), res = 400, crs = crs(atg))
  })
  atg_rast <- rasterize(atg, atg_rast_layer)
  # Check if all values are NA
  if (all(is.na(terra::values(atg_rast)))) {
    message("No valid pixels found. Retrying with touches=TRUE...")
    atg_rast <- rasterize(atg, atg_rast_layer, touches = T)
  }
  
  # Initialize raster list with ATG
  raster_list <- list(atg_rast)
  
  # Read R1 if it exists
  if (file.exists(r1_shp)) {
    r1 <- vect(r1_shp)
    r1_rast_layer <- tryCatch({
      rast(ext(r1), res = 400, crs = crs(r1)) 
    }, error = function(e) {
      r1_buff <- buffer(r1, width = 200)
      rast(ext(r1_buff), res = 400, crs = crs(r1))
    })
    r1_rast <- rasterize(r1, r1_rast_layer)
    raster_list <- append(raster_list, list(r1_rast)) # Add R1 to list
  } else {
    message("Skipping R1: ", r1_shp, " (R1 does not exist for this project")
  }
  
  # Read T1 if it exists
  if (file.exists(t1_shp)) {
    t1 <- vect(t1_shp)
    t1_rast_layer <- tryCatch({
      rast(ext(t1), res = 400, crs = crs(t1)) 
    }, error = function(e) {
      t1_buff <- buffer(t1, width = 200)
      rast(ext(t1_buff), res = 400, crs = crs(t1))
    })
    t1_rast <- rasterize(t1, t1_rast_layer)
    raster_list <- append(raster_list, list(t1_rast)) # Add T1 to list
  } else {
    message("Skipping T1: ", t1_shp, " (T1 does not exist for this project)")
  }
  
  # Merge only the existing rasters
  collection <- sprc(raster_list)
  project <- merge(collection)
  
  return(project)
}

# Create function to loop through folder and rasterize all projects ####
rasterize_folder <- function(project_folder, r1_folder, t1_folder, output_dir) {
  # Get all ATG shapefiles in selected folder
  atg_files <- list.files(project_folder, pattern = ".shp", full.names = TRUE)
  
  for (atg_shp in atg_files) {
    # Extract project-specific name
    project_name <- trimws(tools::file_path_sans_ext(basename(atg_shp)))
    
    # Construct R1 and T1 file paths
    r1_shp <- file.path(r1_folder, paste0(project_name, "_R1.shp"))
    t1_shp <- file.path(t1_folder, paste0(project_name, "_T1.shp"))
    
    # Run rasterization function with error handling
    raster_output <- tryCatch({
      rasterize_projects(atg_shp, r1_shp, t1_shp)
    }, error = function(e) {
      message("Skipping ", project_name, " due to error: ", e$message)
      return(NULL)  # Return NULL so it doesn't break the loop
    })
    
    # Save raster output if successful
    if (!is.null(raster_output)) {
      output_path <- file.path(output_dir, paste0(project_name, ".tif"))
      dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
      writeRaster(raster_output, output_path, overwrite = TRUE)
      message(paste(project_name, "saved as raster"))
    }
  }
}

# Pump Storage ####
# pump storage have multiple shapefiles that need to be rasterized and joined prior to joining with r1t1
rasterize_pump <- function(atg_folder, r1_shp, t1_shp) {
  
  # Get list of ATG shapefiles in the folder
  atg_shps <- list.files(atg_folder, pattern = ".shp", full.names = TRUE)
  
  atg_rasters <- list()
  
  # Process each ATG shapefile
  for (atg_shp in atg_shps) {
    atg <- vect(atg_shp) 
    atg_rast_layer <- tryCatch({
      rast(ext(atg), res = 400, crs = crs(atg)) 
    }, error = function(e) {
      atg_buff <- buffer(atg, width = 200)
      rast(ext(atg_buff), res = 400, crs = crs(atg))
    })
    atg_rast <- rasterize(atg, atg_rast_layer)
    
    # Check if all values are NA
    if (all(is.na(terra::values(atg_rast)))) {
      message("No valid pixels found for ", atg_shp, ". Retrying with touches = TRUE...")
      atg_rast <- rasterize(atg, atg_rast_layer, touches = TRUE)
    }
    
    atg_rasters <- append(atg_rasters, list(atg_rast))
  }
  
  # Merge all ATG rasters
  if (length(atg_rasters) > 0) {
    atg_merged <- merge(sprc(atg_rasters))
  } else {
    atg_merged <- NULL
  }
  
  raster_list <- list()
  
  if (!is.null(atg_merged)) {
    raster_list <- append(raster_list, list(atg_merged))
  }
  
  # Read and process R1 if it exists
  if (file.exists(r1_shp)) {
    r1 <- vect(r1_shp)
    r1_rast_layer <- tryCatch({
      rast(ext(r1), res = 400, crs = crs(r1)) 
    }, error = function(e) {
      r1_buff <- buffer(r1, width = 200)
      rast(ext(r1_buff), res = 400, crs = crs(r1))
    })
    r1_rast <- rasterize(r1, r1_rast_layer)
    raster_list <- append(raster_list, list(r1_rast)) # Add R1 to list
  } else {
    message("Skipping R1: ", r1_shp, " (R1 does not exist for this project)")
  }
  
  # Read and process T1 if it exists
  if (file.exists(t1_shp)) {
    t1 <- vect(t1_shp)
    t1_rast_layer <- tryCatch({
      rast(ext(t1), res = 400, crs = crs(t1)) 
    }, error = function(e) {
      t1_buff <- buffer(t1, width = 200)
      rast(ext(t1_buff), res = 400, crs = crs(t1))
    })
    t1_rast <- rasterize(t1, t1_rast_layer)
    raster_list <- append(raster_list, list(t1_rast)) # Add T1 to list
  } else {
    message("Skipping T1: ", t1_shp, " (T1 does not exist for this project)")
  }
  
  # Merge only the existing rasters
  if (length(raster_list) > 0) {
    collection <- sprc(raster_list)
    project <- merge(collection)
  } else {
    message("No valid rasters found for this project.")
    project <- NULL
  }
  
  return(project)
}

# Rasterize folder with the small change of changing the function to rasterize_pump instead of just rasterize projects
rasterize_pump_folder <- function(project_folder, r1_folder, t1_folder, output_dir) {
  # Get all project subfolders (assuming each project has its own folder inside project_folder)
  project_subfolders <- list.dirs(project_folder, recursive = FALSE)
  
  for (project_path in project_subfolders) {
    # Extract project-specific name
    project_name <- basename(project_path)
    
    # Construct R1 and T1 file paths
    r1_shp <- file.path(r1_folder, paste0(project_name, "_R1.shp"))
    t1_shp <- file.path(t1_folder, paste0(project_name, "_T1.shp"))
    
    # Run rasterization function
    raster_output <- rasterize_pump(project_path, r1_shp, t1_shp)
    
    # Save raster output if it is not NULL
    if (!is.null(raster_output)) {
      output_path <- file.path(output_dir, paste0(project_name, ".tif"))
      dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
      writeRaster(raster_output, output_path, overwrite = TRUE)
      
      message(paste(project_name, "saved as raster"))
    } else {
      message(paste("No valid raster output for", project_name))
    }
  }
}

# Rasterize T1R1 only ####
# general function that could also be used to rasterize t1r1s if only those are needed
rasterize_t1r1 <- function(atg_shp, r1_shp, t1_shp) {
  
  # Read ATG to extract project name
  atg <- vect(atg_shp) 
  project_name <- atg$Project_Na[1] # Assuming 'Project_Na' holds the project name
  
  # Initialize raster list (excluding ATG)
  raster_list <- list()
  
  # Read R1 if it exists
  if (file.exists(r1_shp)) {
    r1 <- vect(r1_shp)
    r1_rast_layer <- tryCatch({
      rast(ext(r1), res = 400, crs = crs(r1)) 
    }, error = function(e) {
      r1_buff <- buffer(r1, width = 200)
      rast(ext(r1_buff), res = 400, crs = crs(r1))
    })
    r1_rast <- rasterize(r1, r1_rast_layer)
    raster_list <- append(raster_list, list(r1_rast)) # Add R1 to list
  } else {
    message("Skipping R1: ", r1_shp, " (R1 does not exist for this project)")
  }
  
  # Read T1 if it exists
  if (file.exists(t1_shp)) {
    t1 <- vect(t1_shp)
    t1_rast_layer <- tryCatch({
      rast(ext(t1), res = 400, crs = crs(t1)) 
    }, error = function(e) {
      t1_buff <- buffer(t1, width = 200)
      rast(ext(t1_buff), res = 400, crs = crs(t1))
    })
    t1_rast <- rasterize(t1, t1_rast_layer)
    raster_list <- append(raster_list, list(t1_rast)) # Add T1 to list
  } else {
    message("Skipping T1: ", t1_shp, " (T1 does not exist for this project)")
  }
  
  # Merge only the existing rasters (R1 and T1, excluding ATG)
  if (length(raster_list) > 0) {
    collection <- sprc(raster_list)
    project <- merge(collection)
    return(project)
  } else {
    message("No valid R1 or T1 rasters found for project: ", project_name)
    return(NULL)
  }
}

rasterize_t1r1_folder <- function(project_folder, r1_folder, t1_folder, output_dir) {
  # Get all ATG shapefiles in selected folder
  atg_files <- list.files(project_folder, pattern = ".shp", full.names = TRUE)
  
  for (atg_shp in atg_files) {
    # Extract project-specific name
    project_name <- trimws(tools::file_path_sans_ext(basename(atg_shp)))
    
    # Construct R1 and T1 file paths
    r1_shp <- file.path(r1_folder, paste0(project_name, "_R1.shp"))
    t1_shp <- file.path(t1_folder, paste0(project_name, "_T1.shp"))
    
    # Run rasterization function with error handling
    raster_output <- tryCatch({
      rasterize_t1r1(atg_shp, r1_shp, t1_shp)
    }, error = function(e) {
      message("Skipping ", project_name, " due to error: ", e$message)
      return(NULL)  # Return NULL so it doesn't break the loop
    })
    
    # Save raster output if successful
    if (!is.null(raster_output)) {
      output_path <- file.path(output_dir, paste0(project_name, ".tif"))
      dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
      writeRaster(raster_output, output_path, overwrite = TRUE)
      message(paste(project_name, "saved as raster"))
    }
  }
}

# rasterize major transmission lines (simple rasterizing of shapefiles)
tx_folder <- "BC Hydro Projects/Shapefiles/Project/Major Transmission"
tx_files <- list.files(tx_folder, pattern = ".shp", full.names = T)
output_folder <- "BC Hydro Projects/Rasters/400 m/Major Tranmsission/"

for (file in tx_files) {
  shp <- vect(file)
  rast_layer <- rast(ext(shp), res = 400, crs = crs(shp))
  raster <- rasterize(shp, rast_layer)
  
  output_filename <- file.path("BC Hydro Projects/Rasters/400 m/Major Transmission", paste0(tools::file_path_sans_ext(basename(file)), ".tif"))
  
  writeRaster(raster, output_filename, overwrite = T)
}