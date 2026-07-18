# Gallery: a Voronoi treemap built with our companion package ggvmap
# (github.com/loukesio/ggvmap), coloured with an ltc palette.
# European countries sized by population -- cell area is proportional to people.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggvmap)
  library(gapminder)
})

eu <- gapminder %>%
  filter(year == 2007, continent == "Europe") %>%
  slice_max(pop, n = 12) %>%
  mutate(country = as.character(country)) %>%
  arrange(desc(pop))

# a light "olga" pastel ramp keeps every cell legible under dark labels
fills <- setNames(ltc_pal("olga", n = nrow(eu), type = "continuous"), eu$country)

vm <- ggvmap(
  weights   = eu$pop,
  labels    = eu$country,
  fill_by   = "label",
  clip      = clip_circle(),
  seed      = 7,
  show_labels = TRUE,
  label_col = INK,
  label_size = 3.4,
  border_col = "white",
  border_size = 1.1,
  legend    = FALSE
)

p <- vm +
  scale_fill_manual(values = fills, guide = "none") +
  labs(
    title    = "Europe, by the millions",
    subtitle = "Twelve most populous European countries in 2007 · cell area scales with population\nA ggvmap Voronoi treemap, coloured with the ltc \"olga\" palette",
    caption  = "Source: Gapminder (2007)  ·  ggvmap + ltc R packages"
  ) +
  theme_ltc() +
  theme(
    axis.title = element_blank(),
    axis.text  = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

gallery_save(p, "voronoi_europe.png", width = 8.4, height = 8.4)
