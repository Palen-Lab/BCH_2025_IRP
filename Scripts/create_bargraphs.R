library(ggplot2)
library(readxl)
library(tidyr)
library(dplyr)

setwd("E:/Github/BC Hydro Project/")

# Specify the file path to your Excel file
file_path <- "BC Hydro Projects/BCH_Project_Summary_250221.xlsx"

# Read the first sheet of the Excel file into a data frame
df <- read_excel(file_path)

df <- df %>%
  arrange(`Scaled Summed Score`) %>%
  mutate(`BC Hydro Names` = factor(`BC Hydro Names`, levels = rev(`BC Hydro Names`)))

write.csv(df, "BC Hydro Projects/BCH_Project_Summary_250221.csv")

names(df)

ggplot(df, aes(y = `BC Hydro Names`)) +
  geom_bar(aes(x = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`, fill = "Terrestrial"), stat = "identity") +
  geom_bar(aes(x = `Freshwater Proportion of Scaled Score`, fill = "Freshwater"), position = "stack", stat = "identity") +
  scale_fill_manual(
    values = c("Terrestrial" = "green", "Freshwater" = "blue")
  ) +
  theme_bw() +
  labs(x = "Scaled Z-Score") +
  theme(axis.text.y = element_text(size = 6)) +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0))

ggplot(df, aes(y = `BC Hydro Names`)) +
  # Stacked bars for Terrestrial and Freshwater
  geom_bar(aes(
    x = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`, 
    fill = "Terrestrial"
  ), stat = "identity") +
  geom_bar(aes(
    x = `Freshwater Proportion of Scaled Score`, 
    fill = "Freshwater"
  ), position = "stack", stat = "identity") +
  # Add a single dot for new updates (combined position of Terrestrial and Freshwater)
  geom_point(data = subset(df, `New Update?` == "y"), 
             aes(x = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`, 
                 y = `BC Hydro Names`), 
             color = "red", size = 2) +
  scale_fill_manual(
    values = c("Terrestrial" = "green", "Freshwater" = "blue")
  ) +
  theme_bw() +
  labs(x = "Scaled Z-Score") +
  theme(axis.text.y = element_text(size = 6)) +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0))

ggsave("Graphics/Bar Graphs/project_z-scores_ranked_250221.jpg", width = 30, height = 75, units = "cm", dpi = 300)

### top 20
df_top20 <- df %>%
  mutate(Total_Score = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`) %>%
  arrange(desc(Total_Score)) %>%
  head(20)

ggplot(df_top20, aes(y = reorder(`BC Hydro Names`, -Total_Score))) +
  geom_bar(aes(x = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`, fill = "Terrestrial"), stat = "identity") +
  geom_bar(aes(x = `Freshwater Proportion of Scaled Score`, fill = "Freshwater"), position = "stack", stat = "identity") +
  scale_fill_manual(
    values = c("Terrestrial" = "green", "Freshwater" = "blue")
  ) +
  theme_bw() +
  labs(x = "Scaled Z-Score") +
  theme(axis.text.y = element_text(size = 6)) +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0))

ggsave("Graphics/Bar Graphs/project_z-scores_ranked_250221_top20.jpg", width = 6, height = 5, units = "in", dpi = 300)

# bottom 20
df_bottom20 <- df %>%
  mutate(Total_Score = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`) %>%
  arrange(Total_Score) %>%  # Ascending order (lowest first)
  head(20)  # Select bottom 20

ggplot(df_bottom20, aes(y = reorder(`BC Hydro Names`, -Total_Score))) +
  geom_bar(aes(x = `Terrestrial Proportion of Scaled Score` + `Freshwater Proportion of Scaled Score`, fill = "Terrestrial"), stat = "identity") +
  geom_bar(aes(x = `Freshwater Proportion of Scaled Score`, fill = "Freshwater"), position = "stack", stat = "identity") +
  scale_fill_manual(
    values = c("Terrestrial" = "green", "Freshwater" = "blue")
  ) +
  theme_bw() +
  labs(x = "Scaled Z-Score") +
  theme(axis.text.y = element_text(size = 6)) +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0))

ggsave("Graphics/Bar Graphs/project_z-scores_ranked_250221_bot20.jpg", width = 5, height = 5, units = "in", dpi = 300)
