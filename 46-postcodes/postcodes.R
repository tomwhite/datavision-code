library(tidyverse)

df <- read_csv("data/postcode_counts.csv")

df %>%
  ggplot(aes(date, num_postcodes, group=area, color=area)) +
  geom_line() +
  theme(legend.position = "none") 
