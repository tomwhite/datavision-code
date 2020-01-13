library(tidyverse)
library(rgdal)
library(cartogram)

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

# https://cengel.github.io/R-spatial/intro.html#loading-shape-files-into-r

wales_spatial <- readOGR("data/HighWaterMark/")
#plot(wales_spatial)

# join pop data (need to preserve order, so don't use merge)
library(plyr)
wales_spatial@data <- join(wales_spatial@data, population)

# Cartograms
# https://www.r-graph-gallery.com/cartogram.html

#wales_cartogram <- cartogram_cont(wales_spatial, "population", itermax=5)
#plot(wales_cartogram)

# sf

library(sf)
#shapefile <- st_read("HighWaterMark/")
#plot(shapefile)

wales_sf = st_as_sf(wales_spatial)

wales_sf <- wales_sf %>%
  st_simplify(preserveTopology=TRUE, dTolerance = 200) %>%
  st_cast("MULTIPOLYGON")
plot(wales_sf)

#str(wales_sf)
#head(wales_sf)
#tail(wales_sf)

#powys = wales_sf[19,]
#head(powys)
#plot(powys)

wales_cartogram_sf <- cartogram_cont(wales_sf, "population", itermax = 15, prepare = "none") %>%
  st_cast("MULTIPOLYGON")
#plot(wales_cartogram_sf["population"])

# TODO: add LA labels
# Using plotly fails due to https://github.com/ropensci/plotly/issues/1659. See also https://community.plot.ly/t/how-to-make-tooltips-show-in-region-rather-than-on-border-map-using-ggplotly/13507

p1 <- ggplot(wales_sf["population"], aes(fill = population/1000, text = wales_sf$name_en)) +
  theme_void() +
  geom_sf() +
  # geom_sf_text(label = wales_sf$name_en, size = 3) + # TODO: specify labels directly (only 22), see https://stackoverflow.com/questions/7611169/intelligent-point-label-placement-in-r
  scale_fill_distiller(palette = "Greens", direction = 1) +
  labs(fill = "Population (thousands)")

#library(plotly)
#ggplotly(p1) %>% style(hoveron = "fill")

p2 <- ggplot(wales_cartogram_sf["population"], aes(fill = population/1000, text = wales_sf$name_en)) +
  theme_void() +
  geom_sf() +
  scale_fill_distiller(palette = "Greens", direction = 1) +
  labs(fill = "Population (thousands)")

#ggplotly(p2) %>% style(hoveron = "fill")

# https://wilkelab.org/cowplot/articles/plot_grid.html
library("cowplot")

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
#plot_grid(prow, legend, rel_widths = c(2, .4))
plot_grid(prow, legend_b, ncol = 1, rel_heights = c(1, .1))

#subplot(ggplotly(p1) %>% style(hoveron = "fill"), ggplotly(p2) %>% style(hoveron = "fill"))

#install.packages("transformr")
library(transformr)

morph <- tween_sf(wales_sf, wales_cartogram_sf,
                  ease = 'linear',
                  nframes = 20)

ggplot(morph) + 
  geom_sf(aes(geometry = geometry, fill = population), colour = 'white' , size = .1) + 
  facet_wrap(~.frame, labeller = label_both, ncol = 3) + 
  coord_sf(datum = NULL) + 
  theme_void()

# TODO: just show side by side view - animation isn't very smooth (lots of gaps appear) and is hard to look at

#remove.packages("gganimate")
#install.packages('gifski')
#install.packages('png')

#install.packages("animation")
#install.packages("/Users/tom/Downloads/gganimate-0.1.1", repos = NULL, type="source")

library(gganimate)


p <- ggplot(morph) + 
  geom_sf(aes(geometry = geometry, fill = population, frame = .frame), colour = 'white' , size = .1) + 
  coord_sf() + 
  theme_void()
  
animation::ani.options(interval = 1/20)
gganimate(p, "animation.gif")
