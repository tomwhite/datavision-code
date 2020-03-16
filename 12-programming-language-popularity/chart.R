library(jsonlite)
library(tidyverse)
library(zoo)

# Create a bump chart based on https://www.r-bloggers.com/bump-chart/

df <- read_json("gh-pull-request.json", simplifyDataFrame = TRUE) %>%
  mutate(count = as.numeric(count)) %>%
  mutate(date = paste0(year, "Q", quarter)) %>%
  mutate(date = as.Date(as.yearqtr(date))) %>%
  select(c("name", "date", "count"))

df.rankings <- df %>% 
  group_by(date) %>% 
  arrange(date, desc(count), name) %>% 
  mutate(ranking = row_number()) %>% 
  as.data.frame()

highest_rankings <- df.rankings %>%
  group_by(name) %>%
  summarize(highest_ranking = min(ranking))

# find total ranking of langs
lang_order <- inner_join(df.rankings, highest_rankings) %>%
  filter(highest_ranking <= 10) %>%
  group_by(name) %>%
  summarise(mean_ranking = mean(ranking)) %>%
  arrange(mean_ranking) %>%
  pull(name)

df.rankings <- inner_join(df.rankings, highest_rankings) %>%
  filter(highest_ranking <= 10) %>%
  mutate(ranking = replace(ranking, ranking > 10, NA))

# https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
colours = c('#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#008080', '#e6beff', '#9a6324', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000')

ranking_ends <- df.rankings %>% 
  group_by(name) %>% 
  top_n(1, date) %>% 
  pull(ranking)

name_ends <- df.rankings %>% 
  group_by(name) %>% 
  top_n(1, date) %>% 
  pull(name)

ggplot(data = df.rankings, aes(x = date, y = ranking, group = factor(name, levels = lang_order))) +
  geom_line(aes(color = factor(name, levels = lang_order)), size = 3, lineend="round") +
  annotate("text", x = as.Date(c("2012-04-01")), y = 9.3, label = "Scala", hjust = "middle", size=3) +
  annotate("text", x = as.Date(c("2012-04-01")), y = 10.3, label = "Objective-C", hjust = "middle", size=3) +
  annotate("text", x = as.Date(c("2014-10-01")), y = 10.3, label = "CSS", hjust = "right", size=3) +
  annotate("text", x = as.Date(c("2013-04-01")), y = 10.3, label = "HTML", hjust = "right", size=3) +
  scale_x_date(date_breaks = "years", date_labels = "%Y") +
  scale_y_reverse(breaks = 1:nrow(df.rankings), sec.axis = sec_axis(~ ., breaks = ranking_ends, labels = name_ends)) +
  scale_color_manual(values=colours) +
  theme_minimal() +
  theme(legend.position = "none", axis.title.x = element_blank()) +
  labs(title = "Programming language popularity",
       subtitle = "Ranked by number of pull requests on GitHub",
       caption = "Data source: GitHub Archive, GitHut")

ggsave("12-programming-language-popularity.png", width = 9, height = 6, dpi = "retina")
