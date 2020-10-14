library(tidyverse)

df <- read_fwf("data/a-levels.txt",
               fwf_widths(c(9, 4, 5, 5, 5, 5, 5, 5, 5, 6, 8),
                          col_names = c("Year", "A*", "A", "B", "C", "D", "E", "N", "U", "A*-E", "Number")),
               skip = 1)

write_csv(df, "data/a-levels.csv")

df <- df %>% select(-c(`A*-E`, Number)) %>%
  pivot_longer(!Year, names_to = "Grade", values_to = "Percentage") %>%
  mutate(Grade = factor(Grade, levels = c("A*", "A", "B", "C", "D", "E", "N", "U")))

write_csv(df, "data/a-levels-tidy.csv")

df %>%
  ggplot(aes(Year, Percentage, fill = Grade)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(breaks = seq(0, 100, 10))
