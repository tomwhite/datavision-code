library(tidyverse)

df <- read.csv("data/Conflict_Catalog_18_vars.csv")

df %>%
  ggplot(aes(EndYear, TotalFatalities)) +
  geom_point() +
  scale_y_continuous(trans='log10')
