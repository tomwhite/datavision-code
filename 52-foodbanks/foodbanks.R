library(tidyverse)
library(cowplot)

foodbanks <- read_csv("data/trussell.csv")

foodbanks %>%
  ggplot(aes(year, parcels)) +
  geom_bar(stat = "identity", fill="#911eb4") +
  scale_y_continuous(name="Food parcels", labels = scales::comma, n.breaks = 10) +
  labs(
    title = "Trussell Trust three-day food parcels",
    caption = "Data source: Trussell Trust. Graphic: Tom White"
  ) +
  theme_minimal() +
  theme(axis.title.x = element_blank())
  
ggsave("52-foodbanks.png", width = 9, height = 6, dpi = "retina")
