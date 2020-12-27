library(tidyverse)
library(ggbeeswarm)
library(RColorBrewer)
library(cowplot)

to_bytes <- function(s) {
  vals <- str_split(s, " ")
  suffix = vals[[1]][2]
  multiplier <- case_when(
    suffix == "B" ~ 1,
    suffix == "KB" ~ 1000,
    suffix == "MB" ~ 1000000,
    suffix == "GB" ~ 1000000000,
    TRUE ~ NaN
  )
  return(as.numeric(vals[[1]][1]) * multiplier)
}

to_bytes_V <- Vectorize(to_bytes)

df <- read_csv("data/metadatavision.csv") %>%
  mutate(`Data size bytes` = to_bytes_V(`Data size`))  

# Visualization library bar chart
p1 <- df %>%
  group_by(`Visualization library`) %>%
  tally() %>%
  ungroup() %>%
  mutate(`Visualization library` = fct_reorder(`Visualization library`, n)) %>%
  ggplot(aes(`Visualization library`, n, fill = `Visualization library`)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(palette = "Dark2") +
  coord_flip() +
  theme_minimal() +
  theme(legend.position = "none", axis.title.x = element_blank())
p1

# Chart family bar chart
p2 <- df %>%
  group_by(`Chart family`) %>%
  tally() %>%
  ungroup() %>%
  mutate(`Chart family` = fct_reorder(`Chart family`, n)) %>%
  ggplot(aes(`Chart family`, n, fill = `Chart family`)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(palette = "Set2") +
  coord_flip() +
  theme_minimal() +
  theme(legend.position = "none", axis.title.x = element_blank())
p2

# Data size beeswarm
p3 <- df %>%
  ggplot(aes(1, `Data size bytes`)) +
  geom_quasirandom(show.legend = FALSE) +
  scale_x_continuous(limits = c(0.1, 1.9)) +
  scale_y_log10(breaks = c(10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9, 10^10, 10^11),
                labels = scales::label_bytes()) +
  theme_minimal_hgrid() +
  theme(axis.title.x = element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
p3

plot_grid(p1, p2, p3, labels = "auto", nrow = 1)

ggsave("53-metadatavision.png", width = 9, height = 3, dpi = "retina")


