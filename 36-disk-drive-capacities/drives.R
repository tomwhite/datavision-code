library(tidyverse)
library(ggplot2)
library(cowplot)

df <- read_csv("data/weeks.csv")

df %>%
  ggplot(aes(week_start, capacity_bytes/1e9, colour=drive_type, size=count)) +
  geom_point(alpha=0.4) +
  scale_x_date(date_labels="%Y", date_breaks="1 year") +
  scale_y_continuous(trans='log2',
                     breaks = c(80, 160, 250, 320, 500, 1000, 1500, 2000, 3000, 4000, 5000, 6000, 8000, 10000, 12000, 14000, 16000),
                     minor_breaks = NULL,
                     labels = c("80 GB", "160 GB", "250 GB", "320 GB", "500 GB", "1 TB", "1.5 TB", "2 TB", "3 TB", "4 TB", "5 TB", "6 TB", "8 TB", "10 TB", "12 TB", "14 TB", "16 TB")) +
  xlab(label = "Date of installation") +
  ylab(label = "Drive capacity") +
  scale_colour_discrete(name="Drive type") +
  scale_size_continuous(name="Drives installed\n(per week)", breaks = c(10, 100, 500, 1000, 3000)) +
  labs(
    title = "Disk drive capacities in Backblaze's data centre",
    caption = "Data source: Backblaze"
  ) +
  theme_minimal()

ggsave("36-disk-drive-capacities.png", width = 9, height = 6, dpi = "retina")

