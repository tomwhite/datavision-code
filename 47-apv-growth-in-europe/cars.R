library(tidyverse)
library(lubridate)
library(cowplot)

# Read data and filter out anything we don't need
df <- read_csv("data/passenger_car_registrations_by_fuel_type.csv", col_types = cols(.default = col_character())) %>%
  type_convert() %>%
  filter(str_detect(date, pattern = "Q")) %>% # quarters
  mutate(date = parse_date_time(date, "Yq")) %>%
  filter(fuel_type %in% c("Petrol", "Diesel", "Total APV")) %>%
  mutate(country = as.factor(country)) %>%
  arrange(country)

# Summarize for Europe
eu <- df %>%
  group_by(date, fuel_type) %>%
  summarize(count = sum(value)) %>%
  mutate(pct = 100 * count / sum(count)) %>%
  mutate(country = "EUROPE") %>%
  mutate(country = as.factor(country))

# eu %>%
#   ggplot(aes(date, prop, group=fuel_type, color=fuel_type)) +
#   geom_line()

# Summarize for each country
per_country <- df %>%
  group_by(date, country, fuel_type) %>%
  summarize(count = sum(value)) %>%
  mutate(pct = 100 * count / sum(count))

# Combine and plot
bind_rows(per_country, eu) %>%
  ggplot(aes(date, pct, group=fuel_type, color=fuel_type)) +
  geom_line() +
  facet_wrap(~ country) +
  scale_y_continuous(name = "Percentage of passenger cars registered") +
  labs(title = "Alternatively Powered Vehicle growth in Europe",
       subtitle = "APVs include electric cars, hybrid cars, and cars using non-petroleum fuels",
       caption = "Data source: European Automobile Manufacturers' Association (ACEA). Graphic: Tom White",
       color = "Fuel type") +
  theme_minimal_grid(font_size = 12) +
  theme(axis.title.x = element_blank())

ggsave("cars.png", width = 10, height = 7, dpi = "retina")


