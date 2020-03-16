library(jsonlite)
library(tidyverse)
library(zoo)

# Convert JSON data to CSV, keeping only languages that made the top ten.
# I tried to use this in a Flourish line race chart, but abandoned the attempt since it only works for
# "races" where the "horses" are the same throughout - i.e. they can't drop in and out. So doing
# a top ten programming languages doesn't work.

df <- read_json("gh-pull-request.json", simplifyDataFrame = TRUE) %>%
  mutate(count = as.numeric(count)) %>%
  mutate(date = paste0(year, " Q", quarter)) %>%
  select(c("name", "date", "count")) %>%
  pivot_wider(names_from = date, values_from = count)

# Rank each language for each date
cols <- df %>% select(contains("20")) %>% names()
for (col in cols) {
  df[[paste(col, "rank")]] = rank(desc(df[[col]]))
}

# Find the highest rank for each language, see https://stackoverflow.com/a/51355038
# Then filter out any languages that have never been in the top ten
rank_col_names <- df %>% select(contains("rank")) %>% names()
top_ten <- df %>%
  mutate(highest_rank = pmin(!!!rlang::syms(rank_col_names))) %>%
  filter(highest_rank <= 10) %>%
  select(-contains("rank"))

write_csv(top_ten, "programming_languages.csv")
