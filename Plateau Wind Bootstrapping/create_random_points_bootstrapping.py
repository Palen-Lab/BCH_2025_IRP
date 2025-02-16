import geopandas as gpd
from shapely.geometry import Point
import random
import rasterio
from rasterstats import zonal_stats
import pandas as pd
import os

# Set directories and file paths
source_workspace = r"E:\\Github\\Plateau Wind Bootstrapping"
output_dir = r"E:\\Github\\Plateau Wind Bootstrapping\\fw_random_pts_output"
input_raster = r"E:\\Github\\Zonation\\400m\\Freshwater\\weighted.tif"

# Plateau names and number of turbines
num_turbines = [26, 44, 13, 50, 20, 20, 13, 18, 35, 31, 29, 41, 101, 126, 73, 45, 45, 95, 113, 45, 57, 69, 17, 24, 30, 69, 47, 52, 40, 30, 49, 14, 30, 20, 29, 26, 24, 19, 23, 28, 37, 47, 17, 61, 10, 30, 29, 10, 21, 35, 12, 51, 23, 33, 8, 7, 7, 39, 67, 61]
plateau_names = ['BC08_01', 'BC08_02', 'BC09_01', 'BC09_02', 'BC10_01', 'BC10_02', 'BC10_03', 'BC10_04', 'BC11_01', 'BC11_02', 'BC13_01', 'BC13_02', 'BC15', 'BC17', 'BC18', 'BC19', 'BC20', 'BC21', 'BC22', 'BC23', 'BC24', 'BC25', 'BC26_01', 'BC26_02', 'BC26_03', 'NC01', 'NC02', 'NC05', 'NC06', 'PC32', 'SI01', 'SI02', 'SI03', 'SI04', 'SI05', 'SI06', 'SI08', 'SI09', 'SI10', 'SI11', 'SI12', 'SI13', 'SI14', 'SI15', 'SI22', 'SI30', 'SI31', 'SI33', 'SI38', 'VI02', 'VI04', 'VI05', 'VI06', 'VI07', 'VI08', 'VI09', 'VI13', 'NC08', 'NC09', 'SI15']

# Function to generate random points within a polygon
def generate_random_points(polygon, num_points):
    minx, miny, maxx, maxy = polygon.bounds
    points = []
    while len(points) < num_points:
        random_point = Point(random.uniform(minx, maxx), random.uniform(miny, maxy))
        if polygon.contains(random_point):
            points.append(random_point)
    return points

# Dictionary to store final results
final_results = {}

# Loop over each plateau
for a, plateau_name in enumerate(plateau_names):
    print(f"Processing plateau: {plateau_name}")

    # Path to the plateau's shapefile
    shapefile_path = os.path.join(r"E:\\Github\\BC Hydro Projects\\Shapefiles\\Project\\Wind\\Plateau Polygons", plateau_name + '.shp')
    plateau_gdf = gpd.read_file(shapefile_path)

    # Skip plateau if the shapefile is empty
    if len(plateau_gdf) == 0:
        print(f"No geometries found in shapefile {shapefile_path}. Skipping.")
        continue

    # Ensure CRS alignment
    with rasterio.open(input_raster) as src:
        raster_crs = src.crs
    if plateau_gdf.crs != raster_crs:
        plateau_gdf = plateau_gdf.to_crs(raster_crs)

    # Bootstrapping: Generate and process 100 iterations of random points
    num_points = num_turbines[a]
    iteration_sums = []  # Store sum of mean values for each iteration

    for i in range(1, 101):  # 100 bootstrap iterations
        print(f"Iteration {i} for plateau {plateau_name}")

        # Generate random points
        random_points = generate_random_points(plateau_gdf.geometry.iloc[0], num_points)
        if not random_points:
            print(f"No valid points generated for {plateau_name}, iteration {i}. Skipping.")
            continue

        # Create GeoDataFrame for random points
        points_gdf = gpd.GeoDataFrame(geometry=random_points, crs=plateau_gdf.crs)

        # Compute zonal statistics
        try:
            stats = zonal_stats(points_gdf, input_raster, stats="mean")
            if not stats:
                print(f"No statistics returned for {plateau_name}, iteration {i}.")
                continue

            # Compute the sum of mean values for this iteration
            iteration_sum = sum(stat['mean'] for stat in stats if stat['mean'] is not None)
            iteration_sums.append(iteration_sum)
        except Exception as e:
            print(f"Error in zonal stats for {plateau_name}, iteration {i}: {e}")

    # Compute the final average of sums for this plateau
    if iteration_sums:
        plateau_average_sum = sum(iteration_sums) / len(iteration_sums)
        final_results[plateau_name] = plateau_average_sum
    else:
        print(f"No valid iterations for plateau {plateau_name}.")
        final_results[plateau_name] = None

# Save final results to a CSV file
results_df = pd.DataFrame(list(final_results.items()), columns=["Plateau", "Average_Sum"])
results_csv = os.path.join(output_dir, "plateau_average_sums.csv")
results_df.to_csv(results_csv, index=False)
print(f"Final results saved to {results_csv}")