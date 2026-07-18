# Gallery: the Booker Prize palettes.
# Five ltc palettes are named after Booker-winning novels. Here each novel is a
# lollipop sized by its page count and coloured with its own ltc palette -- a
# chart only this package could make.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

books <- tibble::tribble(
  ~palette,      ~title,                  ~author,           ~year, ~pages,
  "midnight",    "Midnight's Children",   "Salman Rushdie",   1981,  446,
  "remains",     "The Remains of the Day","Kazuo Ishiguro",   1989,  258,
  "luminaries",  "The Luminaries",        "Eleanor Catton",   2013,  832,
  "lincoln",     "Lincoln in the Bardo",  "George Saunders",  2017,  343,
  "shuggie",     "Shuggie Bain",          "Douglas Stuart",   2020,  430
) %>%
  # each palette contributes a stick colour (dark) and a dot colour (accent),
  # pulled straight from the package so they can never drift.
  mutate(
    stick = vapply(palette, function(p) {
      cols <- ltc_palettes[[p]]
      cols[which.min(colSums(grDevices::col2rgb(cols)))]      # darkest swatch
    }, character(1)),
    dot = vapply(palette, function(p) {
      cols <- ltc_palettes[[p]]
      cols[which.max(apply(grDevices::col2rgb(cols), 2,
                           function(x) max(x) - min(x)))]     # most saturated
    }, character(1)),
    label = paste0(title, "  ·  ", author, " (", year, ")")
  ) %>%
  arrange(pages) %>%
  mutate(label = factor(label, levels = label))

p <- ggplot(books, aes(x = pages, y = label)) +
  geom_segment(aes(x = 0, xend = pages, yend = label, colour = stick),
               linewidth = 1.1) +
  geom_point(aes(colour = dot), size = 8) +
  geom_text(aes(label = pages), colour = "white", family = "plexmono",
            fontface = "bold", size = 2.7) +
  scale_colour_identity() +
  scale_x_continuous(limits = c(0, 900), breaks = seq(0, 800, 200),
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    title    = "Five winners, five palettes",
    subtitle = "Every ltc \"Booker\" palette is named for a Booker Prize novel.\nEach lollipop is coloured with its own palette and scaled by page count.",
    x = "Pages (first edition)", y = NULL,
    caption  = "Page counts: first editions  ·  ltc R package"
  ) +
  theme_ltc() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(family = "plexsans", colour = INK, hjust = 0,
                               size = 10.5),
    axis.ticks = element_blank()
  )

gallery_save(p, "booker_prize.png", width = 9.5, height = 5.6)
