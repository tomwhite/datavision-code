library(tidyverse)
library(ggplot2)
library(cowplot)

# Based on a visualization from https://github.com/clauswilke/dataviz (Figure 10-7)

years <- 1945:2019

load_files <- function(pattern) {
  files <- paste0("data/", pattern, years, ".csv")
  df.list <- setNames(lapply(files, read_csv, skip = 6), years)
  bind_rows(df.list, .id = "Year")
}

lower <- load_files("field_current_members_number_any__lower_chamber_") %>%
  full_join(load_files("current_women_percent_any__lower_chamber_")) %>%
  mutate(`Number of women` = round(`Current number of members` * `Percentage of women` / 100, 0))

upper <- load_files("field_current_members_number_any__upper_chamber_") %>%
  full_join(load_files("current_women_percent_any__upper_chamber_")) %>%
  mutate(`Number of women` = round(`Current number of members` * `Percentage of women` / 100, 0))

df <- bind_rows(lower, upper) %>%
  mutate_all(type.convert) %>%
  group_by(Year) %>%
  summarise(`Total members` = sum(`Current number of members`), `Total women` = sum(`Number of women`, na.rm = TRUE), `Women` = 100 * `Total women` / `Total members`, `Men` = 100 - `Women`) %>%
  gather(key = "Gender", value = "Percentage", `Women`, `Men`)

plot_base <- df %>%
  ggplot(aes(Year, Percentage, fill = Gender)) +
  geom_bar(stat = "identity") +
  geom_hline(
    yintercept = c(50),
    color = "black", size = 0.4, linetype = 2
  ) +
  geom_hline(yintercept = 100, color = "black") +
  scale_x_discrete(
    limits=df$Year,
    breaks=df$Year[seq(1,length(df$Year), by=5)],
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    name = "Proportion of women",
    labels = scales::percent_format(accuracy = 1, scale = 1),
    expand = c(0, 0)
  ) +
  scale_fill_manual(values = c("#E69F00E0", "#56B4E9E0"), guide = "none") +
  labs(
    title = "Proportion of women in national parliaments over time, 1945 to 2019",
    caption = "Data source: Inter-Parliamentary Union"
  ) +
  theme_cowplot()

labels <- filter(df, Year == max(Year)) %>%
  mutate(pos = cumsum(Percentage) - 0.5*Percentage)

yax <- axis_canvas(plot_base, axis = "y") +
  geom_text(data = labels, aes(y = pos, label = paste0(" ", Gender)),
            x = 0, hjust = 0, size = 14/.pt)

ggdraw(insert_yaxis_grob(plot_base, yax, grid::unit(.15, "null")))

ggsave("01-women-in-parliament.png", width = 9, height = 6, dpi = "retina")
