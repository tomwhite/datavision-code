library(tidyverse)
library(ggplot2)

neos <- read_csv("data/sbdb.csv", col_names = TRUE, cols(pdes = col_character(), diameter = col_double()))

close_approaches <- read_csv("data/close-approaches.csv", col_names = FALSE)

close_approaches %>%
  ggplot(aes(X3, X5)) +
  geom_point()

x <- left_join(close_approaches, neos, by = c("X1" = "pdes"))

x %>% filter(!is.na(diameter))

###

close_approaches <- read_csv("data/cneos_closeapproach_data_1ld_clean.csv")

close_approaches %>%
  ggplot(aes(Date, `Minimum Distance`, size=`Lower Diameter Range`)) +
  geom_point(shape=20) +
  geom_vline(xintercept = as.numeric(as.Date("2020-03-5")))

close_approaches %>%
  ggplot(aes(`Lower Diameter Range`)) +
  geom_histogram()

close_approaches_20ld <- read_csv("data/cneos_closeapproach_data_20ld_clean.csv")

close_approaches_20ld %>%
  filter(`Lower Diameter Range` > 1000) %>%
  ggplot(aes(Date, `Minimum Distance`, size=`Lower Diameter Range`)) +
  geom_point(shape=20, alpha=0.5) +
  geom_vline(xintercept = as.numeric(as.Date("2020-03-5")))

close_approaches_20ld %>%
  filter(`Lower Diameter Range` > 150) %>%
  ggplot(aes(`Minimum Distance`, Date, size=`Lower Diameter Range`)) +
  geom_point(shape=20, alpha=0.5) +
  geom_hline(yintercept = as.numeric(as.Date("2020-03-5")))
