# Gallery: Gapminder bubble chart.
# Life expectancy vs income, bubbles sized by population and coloured by
# continent with a discrete ltc palette. The classic "scale types" example.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggrepel)
  library(gapminder)
})

dat <- gapminder %>%
  filter(year == 2007) %>%
  mutate(continent = factor(continent,
                            levels = c("Africa", "Americas", "Asia",
                                       "Europe", "Oceania")))

# a few landmarks to label, chosen to span the space
mark <- dat %>% filter(country %in% c("China", "India", "United States",
                                      "Japan", "Nigeria", "Germany",
                                      "Brazil", "South Africa"))

# "expevo" -- the palette ltc ships "for biologists" -- gives five well
# separated hues, one per continent.
cont_cols <- ltc_pal("expevo", n = 5)

p <- ggplot(dat, aes(gdpPercap, lifeExp)) +
  geom_point(aes(size = pop, fill = continent),
             shape = 21, colour = "white", stroke = 0.4, alpha = 0.9) +
  ggrepel::geom_text_repel(
    data = mark, aes(label = country),
    family = "plexsans", size = 3.1, colour = INK,
    seed = 42, min.segment.length = 0, box.padding = 0.6,
    segment.colour = SUBTLE, segment.size = 0.3
  ) +
  scale_fill_manual(values = cont_cols, name = NULL) +
  scale_size_area(max_size = 20, guide = "none") +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1),
                breaks = c(500, 1000, 2000, 5000, 10000, 20000, 50000)) +
  scale_y_continuous(breaks = seq(40, 85, 10)) +
  labs(
    title    = "The wealth-health curve",
    subtitle = "Life expectancy against income per person in 2007 · bubble area is population · coloured by continent with ltc \"expevo\"",
    x = "GDP per capita (log scale)", y = "Life expectancy (years)",
    caption  = "Source: Gapminder (2007)  ·  ltc R package"
  ) +
  guides(fill = guide_legend(override.aes = list(size = 5, alpha = 1))) +
  theme_ltc() +
  theme(
    legend.position = c(0.99, 0.02),
    legend.justification = c(1, 0),
    legend.background = element_rect(fill = "white", colour = NA),
    legend.key = element_blank(),
    panel.grid.minor = element_blank()
  )

gallery_save(p, "bubble_gapminder.png", width = 9.6, height = 6.4)
