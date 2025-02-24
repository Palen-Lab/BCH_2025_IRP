library(ggplot2)
library(dplyr)

setwd("E:/Github/BC Hydro Project/")

old <- read.csv("BC Hydro Projects/BCH_Project_Summary_250222_old_weight.csv")
new <- read.csv("BC Hydro Projects/BCH_Project_Summary_250221.csv")

# Extract only 'Scaled.Summed.Score' and 'BC.Hydro.Names' columns
old_scores <- old %>%
  select(BC.Hydro.Names, Scaled.Summed.Score)

new_scores <- new %>%
  select(BC.Hydro.Names, Scaled.Summed.Score)

# Merge the old and new scores by 'BC.Hydro.Names'
comparison <- old_scores %>%
  right_join(new_scores, by = "BC.Hydro.Names", suffix = c("_old", "_new"))

# Calculate the difference between old and new scores
comparison <- comparison %>%
  mutate(score_difference = Scaled.Summed.Score_new - Scaled.Summed.Score_old)

# Rank the scores in both the old and new datasets
comparison <- comparison %>%
  mutate(
    rank_old = rank(-Scaled.Summed.Score_old, na.last = "keep", ties.method = "first"),
    rank_new = rank(-Scaled.Summed.Score_new, ties.method = "first"),
    rank_difference = rank_new - rank_old
  )

# Optionally, summarize the differences (e.g., mean, range)
summary_stats <- comparison %>%
  summarize(
    mean_old_score = mean(Scaled.Summed.Score_old, na.rm = TRUE),
    mean_new_score = mean(Scaled.Summed.Score_new, na.rm = TRUE),
    med_old_score = median(Scaled.Summed.Score_old, na.rm = TRUE),
    med_new_score = median(Scaled.Summed.Score_new, na.rm = TRUE),
    mean_difference = mean(score_difference, na.rm = TRUE),
    min_difference = min(score_difference, na.rm = TRUE),
    max_difference = max(score_difference, na.rm = TRUE)
  )

# Combine the old and new scores into a single data frame for plotting using pivot_longer
comparison_long <- comparison %>%
  pivot_longer(cols = c(Scaled.Summed.Score_old, Scaled.Summed.Score_new),
               names_to = "score_type",
               values_to = "score")

# Remove NAs for the old scores, but keep all new scores (even if they are outside 0-1)
comparison_long <- comparison_long %>%
  filter(!is.na(score)) # This ensures NA values are removed but leaves out-of-range new scores

# Boxplot comparing the old and new scores
ggplot(comparison_long, aes(x = score_type, y = score, fill = score_type)) +
  geom_boxplot() +
  labs(
    title = "Boxplot of Old vs. New Scaled Summed Scores",
    x = "Score Type",
    y = "Scaled Summed Score"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("lightcoral", "lightblue"), )

ggsave("Graphics/Old vs New/boxplot_comparison_240221.jpg", width = 10, height = 5, units = "in", dpi = 300)

# Violin plot comparing old and new score with horizontal mean lines
ggplot(comparison_long, aes(x = score_type, y = score, fill = score_type)) +
  geom_violin() +
  labs(
    title = "Violin Plot of Old vs. New Scaled Summed Scores",
    x = "Score Type",
    y = "Scaled Summed Score"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("lightcoral", "lightblue"))

ggsave("Graphics/Old vs New/violin_comparison_240221.jpg", width = 5, height = 5, units = "in", dpi = 300)


# Density plot comparing old and new scores
ggplot(comparison_long, aes(x = score, fill = score_type, color = score_type)) +
  geom_density(alpha = 0.5, outline.type = "full") +
  labs(
    title = "Density Plot of Old vs. New Scaled Summed Scores",
    x = "Scaled Summed Score",
    y = "Density"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("lightcoral", "lightblue")) +
  scale_color_manual(values = c("red", "lightblue4"))

ggsave("Graphics/Old vs New/density_comparison_240222_old_weigh.jpg", width = 10, height = 5, units = "in", dpi = 300)


# finding the distribution of only newly added projects
df <- read.csv("BC Hydro Projects/BCH_Project_Summary_250221.csv")
# Assuming your data is in a dataframe called `df`
df_new <- df %>% filter(`New.Update.` == "y")

# Histogram with Density Curve
ggplot(df_new, aes(x = Scaled.Summed.Score)) + 
  geom_histogram(aes(y = ..count..), bins = 30, fill = "steelblue", alpha = 0.6) +  
  ##geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of Scaled Environmental Scores (New Updated Projects)",
       x = "Scaled Environmental Score") +
  theme_minimal()
