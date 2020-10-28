library(tidyverse)

people <- read_csv("data/Crickhowell1881CensusDataWithOccupation.csv") %>%
  drop_na(Gender) %>%
  drop_na(`Category of Work`) %>%
  drop_na(`Occupation`)  

all <- tibble(
  name = "All", 
  parent = NA, 
  value = NaN
) %>%
  mutate_at("value", as.integer)

categories <- people %>%
  group_by(`Category of Work`) %>%
  tally(sort = T) %>%
  ungroup() %>%
  mutate(name=`Category of Work`, parent="All", value=NaN) %>%
  mutate_at("value", as.integer) %>%
  select(name, parent, value)

occupations <- people %>%
  group_by(`Occupation`, `Category of Work`) %>%
  tally(sort = T) %>%
  ungroup() %>%
  mutate(name=`Occupation`, parent=`Category of Work`, value=n) %>%
  select(name, parent, value)


tree <- bind_rows(all, categories, occupations)

write_csv(tree, "data/tree.csv", na = "")
