# Based on https://www.kaggle.com/rtatman/lego-colors
library(tidyverse)
library(ggplot2)

sets <- read_csv("data/sets.csv")
inventories <- read_csv("data/inventories.csv")
inventory_parts <- read_csv("data/inventory_parts.csv")
colours <- read_csv("data/colors.csv")

colours <- colours %>% mutate(rgb = paste0("#", rgb))

brick_colours <- sets %>% left_join(inventories, by = "set_num") %>%
  left_join(inventory_parts, by = c("id" = "inventory_id")) %>%
  left_join(colours, by = c("color_id" = "id")) %>%
  mutate(colour = name.y) %>%
  select(year, colour, rgb, is_trans, quantity) %>% 
  na.omit %>%
  group_by(year, colour, rgb, is_trans) %>% 
  summarize(total = sum(quantity)) %>%
  arrange(year, desc(total)) %>%
  ungroup()

write_csv(brick_colours, "data/lego-colours.csv")

colours_per_year <- brick_colours %>%
  group_by(year) %>%
  tally()

distinct_colours <- brick_colours %>%
  select(colour, rgb) %>%
  distinct(colour, rgb)

duplicate_rgbs <- distinct_colours %>%
  group_by(rgb) %>%
  summarise(count = n()) %>%
  filter(count > 1)

# There are no duplicate colour names
distinct_colours %>%
  group_by(colour) %>%
  summarise(count = n()) %>%
  filter(count > 1)

distinct_colours %>%
  filter(rgb %in% duplicate_rgbs$rgb) %>%
  arrange(rgb)

