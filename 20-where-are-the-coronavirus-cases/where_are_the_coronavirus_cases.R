#install.packages("cowplot")
#options(download.file.method= "libcurl")
#remotes::install_github("clauswilke/colorblindr")

library(colorblindr)
library(cowplot)
library(tidyverse)
library(zoo)

# Latest data is at https://raw.githubusercontent.com/tomwhite/covid-19-uk-data/master/data/covid-19-indicators-uk.csv
cases <- read_csv("data/covid-19-indicators-uk.csv") %>%
  filter(Indicator == "ConfirmedCases") %>% # only interested in cases
  pivot_wider(names_from = c(Indicator, Country), values_from = Value) %>% # widen so we can compute rolling means
  mutate(DailyConfirmedCases_UK = ConfirmedCases_UK - lag(ConfirmedCases_UK)) %>%
  mutate(DailyConfirmedCases_England = ConfirmedCases_England - lag(ConfirmedCases_England)) %>%
  mutate(DailyConfirmedCases_Scotland = ConfirmedCases_Scotland - lag(ConfirmedCases_Scotland)) %>%
  mutate(DailyConfirmedCases_Wales = ConfirmedCases_Wales - lag(ConfirmedCases_Wales)) %>%
  mutate(DailyConfirmedCases_NI = `ConfirmedCases_Northern Ireland` - lag(`ConfirmedCases_Northern Ireland`)) %>%
  select(-starts_with("ConfirmedCases")) %>%
  mutate(RollingDailyConfirmedCases_UK = rollmean(DailyConfirmedCases_UK, 7, align = "right", na.pad=TRUE)) %>%
  mutate(RollingDailyConfirmedCases_England = rollmean(DailyConfirmedCases_England, 7, align = "right", na.pad=TRUE)) %>%
  mutate(RollingDailyConfirmedCases_Scotland = rollmean(DailyConfirmedCases_Scotland, 7, align = "right", na.pad=TRUE)) %>%
  mutate(RollingDailyConfirmedCases_Wales = rollmean(DailyConfirmedCases_Wales, 7, align = "right", na.pad=TRUE)) %>%
  mutate(RollingDailyConfirmedCases_NI = rollmean(DailyConfirmedCases_NI, 7, align = "right", na.pad=TRUE)) %>%
  select(-starts_with("DailyConfirmedCases")) %>%
  filter(Date >= "2020-04-10" & Date <= "2020-05-11")

uk_nations = c("England", "Scotland", "Wales", "NI")

p <- cases %>%
  select(-RollingDailyConfirmedCases_UK) %>%
  pivot_longer(cols = starts_with("RollingDailyConfirmedCases"), names_to = "UK nation", values_to = "Value", values_drop_na = TRUE) %>%
  mutate(`UK nation` = factor(sub('.*_', '', `UK nation`), levels = uk_nations)) %>%
  ggplot() +
  geom_area(aes(Date, Value, fill=`UK nation`)) +
  geom_line(data = cases, aes(Date, RollingDailyConfirmedCases_UK)) +
  scale_fill_OkabeIto() +
  scale_y_continuous(name="Daily confirmed cases", breaks = seq(0, 5000, 1000)) +
  labs(
    title = "Where are the coronavirus cases?",
    subtitle = "Daily confirmed cases of coronavirus in the UK (7-day rolling average)",
    caption = "Data source: UK public health agencies. Graphic: Tom White"
  ) +
  theme_minimal_grid() +
  theme(axis.title.x = element_blank()) + # remove x axis title
  theme(legend.title = element_blank())

plot <- ggdraw(p) + 
  draw_label("UK", x = 0.8, y = 0.7) +
  draw_label("Where are\nthese cases?", x = 0.65, y = 0.6)

plot
  
save_plot("where_are_the_coronavirus_cases.png", plot)
