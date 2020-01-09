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
  st_simplify(preserveTopology=TRUE, dTolerance = 200)
plot(wales_sf)

#str(wales_sf)
#head(wales_sf)
#tail(wales_sf)

#powys = wales_sf[19,]
#head(powys)
#plot(powys)

wales_cartogram_sf <- cartogram_cont(wales_sf, "population", itermax=5)
plot(wales_cartogram_sf["population"])

# produces a blank plot...
ggplot(wales_cartogram_sf["population"]) +
  theme_void() + # see https://github.com/tidyverse/ggplot2/issues/2252#issuecomment-551968071
  geom_sf()

# Chloropeth

# Doesn't work...
library(broom)
wales_cartogram_tidy <- tidy(wales_cartogram, region="name_en")
wales_cartogram_tidy = wales_cartogram_tidy %>% left_join(. , wales_cartogram@data, by=c("id"="name_en")) 
ggplot() +
  geom_polygon(data = wales_cartogram_tidy, aes(fill = population.y, x = long, y = lat, group = group) , size=0, alpha=0.9) +
  coord_map() +
  theme_void()
