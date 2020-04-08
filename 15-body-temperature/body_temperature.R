library(tidyverse)
library(ggplot2)

# There are three datasets here:
# UAVCW - 1880s, 1890s, 1900s (it ran for longer than this, but I've discarded other decades as they had much less data), men only
# NHANES - 1970s
# STRIDE - 2000s, 2010s

palette_OkabeIto <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

combinedData <- read.csv("Data Files/combined_data.csv")

subset <- combinedData %>%
  mutate(study_decade = as.factor(exam_year %/% 10 * 10)) %>%
  filter(!is.na(study_decade)) %>%
  group_by(study_decade) %>%
  filter(n() > 2000) %>%
  ungroup()
  
subset %>%
  group_by(study_decade) %>%
  tally()

subset %>%
  ggplot(aes(age, temp, color=study_decade, fill=study_decade)) + 
  geom_smooth(alpha=0.1) +
  theme_minimal() +
  xlab("Age") +
  scale_y_continuous(
    "Temperature (°F)",
    breaks=c(97.9, 98, 98.6),
    minor_breaks = seq(97, 99, 0.1),
    labels=c("97.9°F", "98°F", "98.6°F"),
    sec.axis = sec_axis(~ (. - 32) * 5/9,
                        name = "Temperature (°C)",
                        breaks=c(36.4, 36.6, 36.8, 37),
                        labels=c("36.4°C", "36.6°C", "36.8°C", "37°C"))
  ) +
  scale_color_manual(name="Decade", values=palette_OkabeIto) +
  scale_fill_discrete(guide=FALSE) +
  labs(
    title = "Human body temperature has decreased since the 19th century",
    caption = "Data source: Protsiv et al. eLife 2020"
  ) +
  facet_grid(. ~ sex)

ggsave("15-body-temperature.png", width = 9, height = 6, dpi = "retina")

