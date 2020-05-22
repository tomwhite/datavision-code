library(tidyverse)
library(ggplot2)
library(cowplot)
library(ggbeeswarm)
library(ggrepel)
library(plotly)

# By default names for food labels are cut off at the first comma, so rewrite some of them to avoid ambiguity
short_names <- c(
  "Barley, pearl, raw" = "Pearl barley",
  "Beans, broad, whole, raw" = "Broad beans",
  "Beans, chick peas, canned, re-heated, drained" = "Chick peas",
  "Bread, white, premium" = "White bread",
  "Flour, wheat, white, plain, soft" = "White flour",
  "Lentils, green and brown, whole, dried, raw" = "Green/brown lentils",
  "Lentils, red, split, dried, raw" = "Red lentils",
  "Pastry, filo, retail, cooked" = "Filo pastry",
  "Peas, split, dried, raw" = "Split peas",
  "Pepper, cayenne, ground" = "Cayenne pepper",
  "Potatoes, new and salad, flesh only, raw" = "New potatoes",
  "Potatoes, old, raw, flesh only" = "Potatoes",
  "Squash, butternut, raw" = "Butternut squash",
  "Sugar, white" = "White sugar",
  "Sugar, brown" = "Brown sugar",
  "Syrup, golden" = "Golden syrup",
  "Wheat, bulgur, raw" = "Bulgur wheat",
  "Yogurt, low fat, plain" = "Low-fat yogurt"
)

shorten <- function(food) {
  food = str_trim(food)
  if (food %in% names(short_names)) {
    return(short_names[food][[1]][1])
  }
  gsub(",.*$", "", as.character(food))
}

foods <- read_csv("/tmp/foods_curated.csv") %>%
  distinct() %>%
  filter(!name %in% c(
    "Beans, haricot, whole, dried, boiled in unsalted water",
    "Carrots, old, raw",
    "Couscous, plain, cooked",
    "Flour, gram",
    "Lentils, green and brown, whole, dried, boiled in unsalted water",
    "Parsnip, boiled in unsalted water",
    "Pasta, egg, white, tagliatelle, fresh, boiled in unsalted water"
  )) %>%
  mutate(label = ifelse(carbs >= 5, lapply(name, shorten), "")) %>%
  mutate(g2 = fct_collapse(g2, `Meat and fish` = c("Meat", "Fish"))) %>%
  mutate(g2 = fct_reorder(g2, carbs, .fun='max'))
  
mutate(g2 = fct_relevel(g2, 
                          "Alcohol",
                          "Eggs", 
                          "Meat and fish",
                          "Fats and oils", 
                          "Milk",
                          "Soups, sauces, and misc",
                          "Herbs and spices",
                          "Nuts and seeds",
                          "Vegetables",
                          "Fruit",
                          "Cereals", 
                          "Sugars and snacks"
                          ))

high_carb_foods <- foods %>% filter(carbs >= 5)

x <- foods %>% filter(g2 == "Vegetables") %>% filter(carbs >= 5)

foods %>% filter(g2 == "Milk")

y <- foods %>% filter(food_code == "11-856") %>%
  mutate(label2 = lapply(name, shorten))

foods %>%
  ggplot(aes(carbs, g2)) +
  geom_point()

pos <- position_jitter(width = 0.3, seed = 2)

x_limits <- c(5, NA) # force labels to be left of 5g so they don't interfere with jittered points

foods %>%
  ggplot(aes(carbs, g2, label = label)) +
  #geom_beeswarm(color = ifelse(foods$label == "", "grey50", "red"), groupOnX = FALSE) +
  #geom_beeswarm(groupOnX = FALSE, position = pos) +
  #geom_jitter(position = pos) +
  geom_point(color = ifelse(foods$label == "", "grey50", "red")) + 
  #geom_vline(xintercept = 5, color = "grey50") +
  #geom_text_repel(position = pos)
  geom_text_repel(segment.alpha = 0.3, point.padding = 0.1,
                  min.segment.length = 0.3,
                  size = 8/.pt,
                  xlim = x_limits) +
  scale_x_continuous(breaks=seq(0,110,10))

# TODO Use beeswarm for points <5 and jitter (or just point) for >5 (since there aren't many of the latter)

foods %>%
  ggplot(aes(carbs, g2, label = label)) +
  geom_jitter(height = 0.3, color = "grey50", alpha = ifelse(foods$carbs < 5, 0.5, 0)) + # trick to only show points with carbs < 5 (o/w factor ordering is lost for some reason)
  #geom_beeswarm(data = filter(foods, carbs < 5), color = "grey50", groupOnX = FALSE) +
  geom_point(data = filter(foods, carbs >= 5), color = "red", alpha = 0.8) + 
  geom_text_repel(segment.alpha = 0.3, point.padding = 0.1,
                  min.segment.length = 0.3,
                  size = 8/.pt,
                  xlim = x_limits) +
  scale_x_continuous(breaks=seq(0,110,10)) +
  labs(
    title = "Carbohydrate content of common food ingredients",
    caption = "Data source: Composition of foods integrated dataset, Public Health England"
  ) +
  xlab(label = "Carbs (g/100g)") +
  theme(axis.title.y = element_blank()) + 
  theme_minimal()

plot <- foods %>%
  ggplot(aes(carbs, g2, label = label, text = name)) +
  geom_beeswarm(groupOnX = FALSE) +
  scale_x_continuous(breaks=seq(0,110,10))

plot %>% ggplotly()

# What foods are we missing from the diagram?

mccance_file = "/Users/tom/projects-workspace/ingreedy-visualization/data/McCance___Widdowson_s_Composition_of_Foods_Integrated_Dataset.csv"
col_names <- names(read_csv(mccance_file, n_max = 0))

mccance <- read_csv(mccance_file, col_names = col_names, skip = 3) %>%
  rename(food_code = "Food Code", name = "Food Name", group = Group, protein = "Protein (g)", fat = "Fat (g)", carbs = "Carbohydrate (g)", cals = "Energy (kcal) (kcal)", fibre = "AOAC fibre (g)") %>%
  select(c(food_code, name, group, protein, fat, carbs, cals, fibre)) %>%
  mutate(carbs = as.numeric(carbs)) %>%
  mutate(g = substr(group, 1, 1)) %>%
  filter(!group %in% c(
    "AE", # pizzas
    "AI", # breakfast cereals
    "AM", # biscuits
    "AN", # cakes
    "AS", # puddings
    "BH", # milk-based drinks
    "DR", # vegetable dishes
    "JR", # fish products and dishes
    "MBG", # burgers and grillsteaks
    "MI", # meat products
    "MR", # meat dishes
    "WC" # sauces
  )) %>%
  mutate(g2 = recode(g,
                     'A' = 'Cereals',
                     'B' = 'Milk',
                     'C' = 'Eggs',
                     'D' = 'Vegetables',
                     'F' = 'Fruit',
                     'G' = 'Nuts and seeds',
                     'H' = 'Herbs and spices',
                     'IF' = 'Baby foods',
                     'J' = 'Fish',
                     'M' = 'Meat',
                     'O' = 'Fats and oils',
                     'P' = 'Beverages',
                     'Q' = 'Alcohol',
                     'S' = 'Sugars and snacks',
                     'W' = 'Soups, sauces, and misc'))

missing <- mccance %>%
  filter(carbs != "N") %>%
  filter(carbs != "Tr") %>%
  filter(carbs >= 5) %>%
  anti_join(foods, by = c("food_code"))

x <- mccance %>% 
  filter(group == 'DG')

missing %>% 
  group_by(g) %>%
  tally() %>%
  arrange(desc(n))

missing %>%
  filter(g == 'F') %>%
  group_by(group) %>%
  tally() %>%
  arrange(desc(n))

x <- missing %>%
  filter(g2 == 'Sugars and snacks')

write_csv(missing, "~/Downloads/curated_missing.csv")

#

add <- mccance %>% filter(food_code %in% c("14-319",
"14-025",
"14-048",
"14-325",
"14-061",
"17-491",
"11-892",
"14-103",
"14-322",
"17-073",
"14-293",
"17-078",
"14-354",
"17-059",
"14-327",
"13-312",
"14-299",
"14-365",
"13-438",
"14-208",
"14-300",
"13-892",
"13-852",
"14-324",
"17-062",
"13-359",
"17-723",
"13-397"))

write_csv(add, "~/Downloads/curated_add.csv")
