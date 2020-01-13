library(tidyverse)
library(rgdal)
library(sf)
library(cartogram)
library(cowplot)
library(plotly)
library(htmlwidgets)

# Population data for all Welsh local authorities

load_population_data <- function(csv = "data/populationestimates-by-localauthority-year.csv") {
  # Source: https://statswales.gov.wales/Catalogue/Population-and-Migration/Population/Estimates/Local-Authority/populationestimates-by-localauthority-year
  read_csv(csv) %>%
    rename(country = X3, local_authority = X4) %>%
    rename_all(gsub, pattern = '^Mid-year (.+)$', replacement = '\\1') %>%
    select(-c(X1, X2))
}

population <- load_population_data() %>%
  filter(!is.na(local_authority)) %>%
  filter(local_authority != "Scotland" & local_authority != "Northern Ireland") %>%
  rename(name_en = local_authority, population = `2018`) %>%
  select(c(name_en, population)) %>%
  arrange(name_en) %>%
  mutate(name_en = as.factor(name_en))

# Boundaries for all Welsh authorities
# Source: http://lle.gov.wales/catalogue/item/LocalAuthorities
# Background: https://cengel.github.io/R-spatial/intro.html#loading-shape-files-into-r

wales_spatial <- readOGR("data/HighWaterMark/")

# Join population data (need to preserve order, so don't use merge)
library(plyr)
wales_spatial@data <- join(wales_spatial@data, population)

wales_sf <- st_as_sf(wales_spatial) %>%
  st_simplify(preserveTopology=TRUE, dTolerance = 200) %>% # reduce data size
  st_cast("MULTIPOLYGON") # this is needed for plotly to work

# Create a cartogram (https://www.r-graph-gallery.com/cartogram.html)

wales_cartogram_sf <- cartogram_cont(wales_sf, "population", itermax = 15, prepare = "none") %>%
  st_cast("MULTIPOLYGON")

# Plot the regular map and the cartogram side by side
# Use cowplot https://wilkelab.org/cowplot/articles/plot_grid.html

p1 <- ggplot(wales_sf["population"], aes(fill = population/1000, text = paste0(wales_sf$name_en, ": ", round(population/1000, 0)))) +
  theme_void() +
  geom_sf() +
  scale_fill_distiller(palette = "Greens", direction = 1) +
  labs(fill = "Population (thousands)")

p2 <- ggplot(wales_cartogram_sf["population"], aes(fill = population/1000, text = paste0(wales_sf$name_en, ": ", round(population/1000, 0)))) +
  theme_void() +
  geom_sf() +
  scale_fill_distiller(palette = "Greens", direction = 1) +
  labs(fill = "Population (thousands)")

legend <- get_legend(
  # create some space to the left of the legend
  p1 + theme(legend.box.margin = margin(0, 0, 0, 12))
)

legend_b <- get_legend(
  p1 + 
    guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "bottom")
)

prow <- plot_grid(
  p1 + theme(legend.position = "none"),
  p2 + theme(legend.position = "none")
)

title <- ggdraw() + 
  draw_label(
    "Population by local authority in Wales (area adjusted), 2018",
    fontface = 'bold',
    x = 0.5
  )

plot_grid(title, prow, legend_b, ncol = 1, rel_heights = c(.1, 0.5, .1))

ggsave("03-wales-population-cartogram.png", width = 9, height = 6, dpi = "retina")

# An interactive version (with tooltips for local authorities) using plotly

interactive <- subplot(ggplotly(p1, tooltip = c('text')) %>% style(hoveron = "fill"), ggplotly(p2, tooltip = c('text')) %>% style(hoveron = "fill"))
saveWidget(interactive, "03-wales-population-cartogram-interactive.html")

# Finally, an animated version, which transitions from the regular map to the area adjusted map.
# I prefer the side-by-side version since the animation isn't very smooth (lots of gaps appear for some reason),
# and it's hard to compare since it keeps moving!

#install.packages("animation")
#install.packages("/Users/tom/Downloads/gganimate-0.1.1", repos = NULL, type="source")

library(gganimate)
library(transformr)

morph <- tween_sf(wales_sf, wales_cartogram_sf,
                  ease = 'linear',
                  nframes = 20)

# Look at the frames statically
ggplot(morph) + 
  geom_sf(aes(geometry = geometry, fill = population), colour = 'white' , size = .1) + 
  facet_wrap(~.frame, labeller = label_both, ncol = 3) + 
  coord_sf(datum = NULL) + 
  theme_void()

# Create an animated gif
p <- ggplot(morph) + 
  geom_sf(aes(geometry = geometry, fill = population, frame = .frame), colour = 'white' , size = .1) + 
  coord_sf() + 
  theme_void()
  
animation::ani.options(interval = 1/20)
gganimate(p, "03-wales-population-cartogram-animation.gif")
