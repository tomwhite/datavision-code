#install.packages("ggridges")

library(tidyverse)
library(ggplot2)
library(ggridges)

pw <- read_csv("/Users/tom/projects-workspace/datavision-code/allowed-password-lengths/data/password-lengths.csv")

pl <- pw %>%
  pivot_longer(c(minlength, maxlength))

pw %>%
  ggplot() +
  geom_bar(aes(minlength), colour="#56B4E9", fill="#56B4E9", alpha=0.5) +
  geom_bar(aes(maxlength), colour="#E69F00", fill="#E69F00", alpha=0.3) +
  scale_x_continuous(breaks=seq(0,130,10))

pl %>%
  ggplot(aes(x = value, colour = name, fill = name, alpha=0.3)) +
  geom_density_line() +
  scale_color_manual(
    values = c("#56B4E9", "#E69F00"),
    breaks = c("minlength", "maxlength"),
    guide = "none"
  ) 

pw %>%
  ggplot()