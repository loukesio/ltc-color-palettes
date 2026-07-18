# Gallery: correlation heatmap with a diverging ltc palette.
# The "heatmap1/2/3" palettes are purpose-built blue-white-red diverging
# scales -- a correlation matrix is exactly what they are for.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

# Pairwise correlations among the numeric mtcars variables, ordered by a
# quick hierarchical clustering so structure reads along the diagonal.
m  <- cor(mtcars)
ord <- hclust(as.dist(1 - m))$order
m  <- m[ord, ord]

cor_df <- as.data.frame(as.table(m)) %>%
  setNames(c("x", "y", "r")) %>%
  mutate(x = factor(x, levels = rownames(m)),
         y = factor(y, levels = rev(rownames(m))))

pal <- ltc_pal("heatmap2", type = "continuous")   # blue - white - red

p <- ggplot(cor_df, aes(x, y, fill = r)) +
  geom_tile(colour = "white", linewidth = 1.1) +
  geom_text(aes(label = sprintf("%.2f", r),
                colour = abs(r) > 0.6),
            family = "plexmono", size = 2.7) +
  scale_fill_gradientn(colours = pal, limits = c(-1, 1),
                       breaks = c(-1, -0.5, 0, 0.5, 1),
                       name = "Correlation",
                       guide = guide_colourbar(barwidth = 0.8, barheight = 9,
                                               ticks.colour = "white",
                                               frame.colour = NA)) +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = INK),
                      guide = "none") +
  coord_fixed(expand = FALSE) +
  labs(
    title    = "What moves together under the hood",
    subtitle = "Pairwise correlation of the mtcars variables, drawn with the ltc \"heatmap2\" diverging palette",
    x = NULL, y = NULL,
    caption  = "Source: mtcars (1974 Motor Trend)  ·  ltc R package"
  ) +
  theme_ltc() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, family = "plexmono"),
    axis.text.y = element_text(family = "plexmono")
  )

gallery_save(p, "heatmap_correlation.png", width = 8.6, height = 7.6)
