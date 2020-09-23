#install.packages("readODS")
library(tidyverse)
library(ggplot2)
library(cowplot)
library(readODS)

# Load data and fix column names
df <- read_ods("data/drt0202.ods", skip=7)
colnames(df) <- c("Age",
                  "Conducted_attempt_1", "Passes_attempt_1", "Pass_rate_attempt_1",
                  "Conducted_attempt_2", "Passes_attempt_2", "Pass_rate_attempt_2",
                  "Conducted_attempt_3", "Passes_attempt_3", "Pass_rate_attempt_3",
                  "Conducted_attempt_4", "Passes_attempt_4", "Pass_rate_attempt_4",
                  "Conducted_attempt_5", "Passes_attempt_5", "Pass_rate_attempt_5",
                  "Conducted_attempt_6", "Passes_attempt_6", "Pass_rate_attempt_6"
)
df <- tibble(df)

# Pull out totals by gender
df <- df %>%
  filter(Age == "Total") %>%
  rename(Gender = Age)
df[1, "Gender"] <- "Male"
df[2, "Gender"] <- "Female"
df[3, "Gender"] <- "Unknown"

# Get total for all genders
all <- df %>% summarize_if(is.numeric, sum, na.rm=TRUE)
df <- df %>% add_row(all)
df[4, "Gender"] <- "All"

# Pivot into tidy form
df <- df %>% pivot_longer(!Gender, names_to = c(".value", "Attempt"),
                    names_pattern = "(.*)_(.)")

# Cumulative pass prob on attempt n is 1 - (product of fail rates from attempt 1 to n)
df <- df %>%
  mutate(Pass_rate_attempt = Passes_attempt / Conducted_attempt) %>%
  mutate(Fail_rate_attempt = 1.0 - Pass_rate_attempt) %>%
  group_by(Gender) %>%
  mutate(Cumulative_fail_prob = cumprod(Fail_rate_attempt)) %>%
  mutate(Cumulative_pass_prob = 1.0 - Cumulative_fail_prob) %>%
  mutate(Cumulative_pass_pct = 100 * Cumulative_pass_prob)

palette_OkabeIto <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

df %>%
  filter(Gender != "Unknown") %>%
  ggplot(aes(Attempt, Cumulative_pass_pct, group=Gender, colour=Gender)) +
  geom_point() +
  geom_line() +
  scale_y_continuous(breaks = c(40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100),
                     labels = c(40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, "100%")) +
  scale_color_manual(
    values = palette_OkabeIto,
    name = "",
    breaks = c("Male", "All", "Female")
  ) +
  xlab(label = "Driving test attempt") +
  ylab(label = "Cumulative pass rate (percent)") +
  labs(
    title = "UK driving test pass rates",
    caption = "Data source: Department for Transport. Graphic: Tom White"
  ) +
  theme_minimal()

ggsave("39-uk-driving-test-pass-rates.png", width = 7, height = 5, dpi = "retina")
