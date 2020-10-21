library(htmlwidgets)
library(leaflet)
library(tidyverse)

df <- read_csv("data/passive-uk-clean.csv")

map <- df %>%
  leaflet(options = leafletOptions(minZoom = 6, maxZoom = 11)) %>%
  addTiles() %>%
  addCircleMarkers(~Longitude, ~Latitude,
                   popup = ~paste(sep = "<br/>", paste0(city, " (", state, ")"), objectType, buildType, baujahr, paste0("<a href='https://passivehouse-database.org/index.php?lang=en#d_", display_id, "'>details</a>")),
                   label=~city,
                   color = "blue",
                   radius = 10,
                   weight = 2)

saveWidget(map, "passive-houses-in-the-uk.html")

# Houses by year
df %>%
  filter(baujahr > 2000) %>%
  ggplot(aes(baujahr)) +
  geom_bar()