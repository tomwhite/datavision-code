library(tidyverse)
library(ggplot2)
library(grid)

# Notes
# Plot all data points - not segmented by sex or ethnicity.
# 677 thousand points, so significant overplotting. Plotted with jitter to try to spread them out,
# but still a lot of overlapping points. Still, the main thrust is clear: many more datapoints
# in most recent study (578K vs 89K for veterans, and 15K for NHANES).
# Banded effect is due to rounding to nearest 0.1 or 0.2 of a degree, espcailly in the earlier studies.
# Red dots show the mean temperature for each birth year.
# Three datasets here.
# First shows that traditional "normal" body temperature of 98.6 F (37C) - dotted grey line - is consistent with this.
# Second and third are lower - 98 F/36.6 C (other study) is consistent.
# Interestingly, the mean temperature for each year in the most recent study goes up,
# but this could be because it is not controlling for other factors.

combinedData <- read.csv("~/Desktop/Temperature study/combined_data.csv")

subset <- combinedData %>%
  filter(sex == "male") %>%
  #filter(race == "white") %>%
  #filter(age >= 40 & age <=60) %>%
  mutate(birth_year_int = round(birth_year, 0)) %>%
  mutate(study = str_extract(study_ID, "[^_]+"))

mean_temp <- subset %>%
  group_by(birth_year_int) %>%
  summarise(mt = mean(temp))

mean_temp_by_study <- subset %>%
  group_by(study) %>%
  summarise(mt = mean(temp))

size_of_studies <- subset %>%
  group_by(study) %>%
  tally()

#mean_temp_nhanes = mean_temp_by_study %>% filter(study == "nhanes") %>% pull()
#mean_temp_stride = mean_temp_by_study %>% filter(study == "stride") %>% pull()
#mean_temp_vet = mean_temp_by_study %>% filter(study == "vet") %>% pull()

# Traditional "normal" body temperature: 98.6 F = 37 C
# More recent study (e.g. https://www.bmj.com/content/359/bmj.j5468): 36.6 C = 97.9 F (approx 98 F)
# Add 98.6 text label to axis using second solution from https://stackoverflow.com/a/29836865
p <- subset %>%
  ggplot(aes(birth_year, temp)) +
  geom_jitter(shape=".", alpha=1/20, height = 0.05, width=0.5) +
  geom_point(data = mean_temp, aes(birth_year_int, mt), colour = "red", size=1) +
  geom_hline(yintercept=98.6, linetype="dashed", alpha=0.2) +
  #geom_hline(yintercept=mean_temp_nhanes) +
  #geom_hline(yintercept=mean_temp_stride) +
  #geom_hline(yintercept=mean_temp_vet) +
  theme_minimal() +
  xlab("Year of birth") +
  scale_y_continuous(
    "Temperature (°F)",
    sec.axis = sec_axis(~ (. - 32) * 5/9, name = "Temperature (°C)")
  ) +
  annotation_custom(textGrob("98.6", gp = gpar(fontsize=8)), 
                    xmin=1785, xmax=1785,ymin=98.6, ymax=98.6) + 
  annotation_custom(textGrob("36.6", gp = gpar(fontsize=8)), 
                    xmin=2010, xmax=2010,ymin=98, ymax=98)
#geom_smooth(data = mean_temp, aes(birth_year_int, mt), colour = "green") +
#geom_smooth(method='lm', formula= y~x)
#geom_bin2d(bins=100)
#stat_density_2d()
p

g = ggplotGrob(p)
g$layout$clip[g$layout$name=="panel"] <- "off"

grid.draw(g)

###

# Plot age

mean_temp_by_age <- subset %>%
  filter(study == "stride") %>%
  group_by(age) %>%
  summarise(mt = mean(temp))

subset %>%
  ggplot(aes(age, temp, color=study)) +
  geom_jitter(shape=".", alpha=1/20, height = 0.05, width=0.5) +
  #geom_point(data = mean_temp_by_age, aes(age, mt), colour = "red", size=1) +
  geom_smooth() +
  theme_minimal() +
  facet_grid(. ~ study)
