library(tidyverse)
library(readxl)
library(cowplot)

path <- "data/planting1976-2020.xlsx"

tree_planting <- function(country, range) {
  read_excel(path, sheet = country, range = range) %>%
    select(c(1, 10)) %>%
    rename(Year = 1, !!country := 2)
}

Kha_to_km_sq <- function(Kha) {
  # There are 100 hectares (ha) in 1 square kilometre
  1000 * Kha * 0.01
}

uk_2024_target_Kha = 30

# Load raw data

raw <- list(tree_planting("England", cell_rows(4:54)),
            tree_planting("Scotland", cell_rows(4:54)),
            tree_planting("Wales", cell_rows(4:54)),
            tree_planting("Northern Ireland", cell_rows(4:49)),
            tree_planting("UK", cell_rows(4:49))) %>%
  reduce(left_join, by = "Year")

# Normalize by country area (https://en.wikipedia.org/wiki/Countries_of_the_United_Kingdom#Statistics)
uk_2024_target_pct = 100 * Kha_to_km_sq(uk_2024_target_Kha) / 242509

df <- raw %>%
  # planting areas are in thousand hectares
  # country areas are in square kilometres
  mutate("England" = 100 * Kha_to_km_sq(`England`) / 130279,
         "Scotland" = 100 * Kha_to_km_sq(`Scotland`) / 77933,
         "Wales" = 100 * Kha_to_km_sq(`Wales`) / 77933,
         "Northern Ireland" = 100 * Kha_to_km_sq(`Northern Ireland`) / 13562,
         "UK" = 100 * Kha_to_km_sq(`UK`) / 242509
         ) %>%
  pivot_longer(!Year, names_to = "Country", values_to = "Percent area planted")


# Plot
df %>%
  ggplot(aes(Year, `Percent area planted`, group=Country, colour=Country)) +
  geom_line() +
  annotate("segment", x = 2024, y = uk_2024_target_pct, xend = 2050, yend = uk_2024_target_pct, colour="black", linetype = 2) +
  annotate("text", x = 2037, y = 0.1, label = "UK 2024-2050 target") +
  expand_limits(x = 2050) +
  scale_x_continuous(n.breaks = 9) +
  scale_color_manual(
    values = c("#56B4E9", "#000000", "#F0E442", "#E69F00", "#009E73"),
    name = "",
    breaks = c("Scotland", "UK", "Northern Ireland", "England", "Wales") # mean order
  ) +
  ylab(label = "Area of country planted in year (percent)") +
  labs(
    title = "UK tree planting rates 1971-2020, by proportion of country",
    caption = "Data source: Forest Research. Graphic: Tom White"
  ) +
  theme_minimal() +
  theme(axis.title.x = element_blank()) + # remove x axis title
  theme(legend.title = element_blank()) +
  theme(legend.position = c(0.875, 0.8)) +
  theme(legend.background = element_rect(fill="white", 
                                         size=0))

ggsave("uk-tree-planting-pct.png", width = 6, height = 4, dpi = "retina")

# Number of trees
trees_per_hectare = 2250 # http://www.cumbriawoodlands.co.uk/woodland-management/creating-a-new-woodland.aspx
uk_2024_target_trees = uk_2024_target_Kha * 1000 * trees_per_hectare / 1e6
raw %>%
  pivot_longer(!Year, names_to = "Country", values_to = "Kha") %>%
  mutate(`Number of trees` = Kha * 1000 * trees_per_hectare / 1e6) %>%
  ggplot(aes(Year, `Number of trees`, group=Country, colour=Country)) +
  geom_line() +
  annotate("segment", x = 2024, y = uk_2024_target_trees, xend = 2050, yend = uk_2024_target_trees, colour="black", linetype = 2) +
  annotate("text", x = 2037, y = 70, label = "UK 2024-2050 target") +
  expand_limits(x = 2050) +
  scale_x_continuous(n.breaks = 9) +
  scale_y_continuous(n.breaks = 8,
                     sec.axis = sec_axis(~ . * 1000 / trees_per_hectare,
                                         name = "Area planted per year (thousand hectares)")) +
  scale_color_manual(
    values = c("#000000", "#56B4E9", "#E69F00", "#009E73", "#F0E442"),
    name = "",
    breaks = c("UK", "Scotland", "England", "Wales", "Northern Ireland") # mean order
  ) +
  ylab(label = "Millions of trees planted in year (at 2250 trees/hectare)") +
  labs(
    title = "UK tree planting rates 1971-2020, by area",
    caption = "Data source: Forest Research. Graphic: Tom White"
  ) +
  theme_minimal() +
  theme(axis.title.x = element_blank()) + # remove x axis title
  theme(legend.title = element_blank()) +
  theme(legend.position = c(0.8, 0.5)) +
  theme(legend.background = element_rect(fill="white", 
                                         size=0))
  
ggsave("uk-tree-planting-area.png", width = 6, height = 4, dpi = "retina")

