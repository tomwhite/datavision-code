library(tidyverse)
library(ggplot2)
library(ggrepel)
library(cowplot)

fields <- read_csv("data/fields.csv") %>%
  # Assume middle of year for Caucher Birkar
  mutate(`Date of birth` = ifelse(Name == "Caucher Birkar", "1 July 1978", `Date of birth`)) %>%  mutate(DOB=dmy(`Date of birth`)) %>%
  mutate(YearStart=dmy(paste("1 Jan", Year))) %>%
  mutate(Age=interval(DOB, YearStart) / years(1))

fields %>%
  ggplot(aes(Year, Age, label=`Last name`)) +
  geom_smooth(method=lm, alpha=0.1, size=0, fill="green") +
  stat_smooth (method=lm, geom="line", alpha=0.3, colour="blue") +
  geom_point() +
  geom_text_repel(min.segment.length = 0.3) +
  scale_x_continuous(name="Year of award", breaks = unique(fields[["Year"]])) +
  scale_y_continuous(name="Age on 1 January in year of award", breaks = seq(27, 41, 1)) +
  labs(
    title = "Is the age of Fields medalists going up?",
    caption = "Data source: Wikipedia/International Mathematical Union. Graphic: Tom White"
  ) +
  theme_minimal_grid()

ggsave("33-age-of-fields-medalists.png", width = 10, height = 7, dpi = "retina")
