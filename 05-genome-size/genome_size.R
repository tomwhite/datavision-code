library(tidyverse)
library(ggplot2)
library(ggridges)
library(ggbeeswarm)
library(cowplot)

# TODO: Show number of species in each category
# TODO: Highlight some interesting species

extract_group <- function(group_str) {
  groups <- str_split(group_str, ';')[[1]]
  if (groups[[1]] != "Eukaryota") {
    return(groups[[1]]);
  }
  if (groups[[2]] == "Fungi" | groups[[2]] == "Protists" | groups[[2]] == "Plants") {
    return(groups[[2]]);
  }
  return(groups[[3]]);
}

genomes <- read_csv("data/genomes.csv") %>%
  mutate(bases = `Size(Mb)` * 1000000) %>%
  rowwise() %>% # needed since following mutate uses a function
  mutate(group = extract_group(`Organism Groups`)) %>%
  filter(`Organism Groups` != "Eukaryota;Other;Other") %>%
  separate(`Organism Groups`, c("Organism1", "Organism2", "Organism3"), sep = ';') %>%
  filter(Organism3 != "Other Animals") %>%
  filter(bases > 0)

genomes %>% group_by(Organism1) %>% count()

genomes %>% group_by(group) %>% count()

counts <- genomes %>% group_by(Organism1, Organism2) %>% count()

eucaryote_counts <- genomes %>%
  filter(Organism1 == 'Eukaryota') %>%
  group_by(Organism1, Organism2, Organism3) %>%
  count()

mammals <- genomes %>% filter(Organism3 == "Mammals")

genomes %>%
  ggplot(aes(bases, reorder(Organism1, bases, FUN=median))) +
  #geom_jitter(shape=".") +
  geom_quasirandom(shape = ".", groupOnX=FALSE) +
  #  geom_density_ridges() +
  scale_x_log10()

set.seed(12345)
genomes %>%
  ggplot(aes(bases, reorder(group, -bases, FUN=median), color = Organism1)) +
  #geom_jitter(shape=".") +
  geom_quasirandom(shape = ".", groupOnX=FALSE, show.legend = FALSE) +
#  geom_density_ridges() +
  scale_x_log10(
    breaks = c(10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9, 10^10),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  xlab("Number of base pairs") +
  labs(
    title = "Genome size",
    caption = "Data source: National Center for Biotechnology Information"
  ) +
  theme_minimal_vgrid() + 
  theme(axis.title.y = element_blank(), axis.line.y = element_blank(),  axis.ticks.y = element_blank()) +
  scale_color_brewer(palette="Dark2")

ggsave("05-genome-size.png", width = 9, height = 6, dpi = "retina")

extremes <- genomes %>%
  group_by(group) %>%
  summarize(smallest = min(bases),
            smallest_species = `#Organism Name`[which(bases == min(bases))],
            largest = max(bases),
            largest_species = `#Organism Name`[which(bases == max(bases))]
            )
