library(tidyverse)
library(cowplot)

angiosperms <- read_csv("data/angiosperms.csv") %>% mutate(group="Angiosperms")
gymnosperms <- read_csv("data/gymnosperms.csv") %>% mutate(group="Gymnosperms")
pteridophytes <- read_csv("data/pteridophytes.csv") %>% mutate(group="Pteridophytes")
bryophytes <- read_csv("data/bryophytes.csv") %>% mutate(group="Bryophytes")

plants = bind_rows(angiosperms, gymnosperms, pteridophytes, bryophytes)

plants <- plants %>%
  select(group, resolved_name, parsed_n) %>%
  drop_na() %>%
  mutate(parsed_n = strsplit(parsed_n, "[,-]")) %>%
  unnest(parsed_n) %>%
  mutate(parsed_n = str_trim(parsed_n)) %>%
  mutate(parsed_n = as.numeric(parsed_n)) %>%
  distinct()

palette_OkabeIto <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")
  
plants %>%
  filter(parsed_n < 100) %>%
  ggplot(aes(parsed_n)) +
  geom_bar(width=0.9, fill="#009E73") +
  scale_x_continuous(name="Number of chromosomes, n (gametophytic)", n.breaks = 10) +
  scale_y_continuous(name="Count") +
  labs(
    title = "Distribution of plant chromosome numbers (n < 100)",
    caption = "Data source: Chromosome Counts Database. Graphic: Tom White"
  ) +
  theme_minimal()

ggsave("41-plant-chromosome-numbers.png", width = 10, height = 7, dpi = "retina")

# Beeswarm by group

library(ggbeeswarm)

plants %>%
  filter(parsed_n < 100) %>%
  ggplot(aes(parsed_n, group, colour=group)) +
  geom_quasirandom(shape = ".", groupOnX=FALSE) +
  scale_x_log10()
