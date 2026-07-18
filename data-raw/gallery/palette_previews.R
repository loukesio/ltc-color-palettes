# Render one clean "preview card" per palette: a 2x2 grid of the package's
# flagship charts -- choropleth map, Gapminder bubble, ggvmap Voronoi treemap,
# continuous heatmap -- all equal size, under the palette's swatches.
# Output: man/figures/previews/<palette>.png
# These images also back the interactive palette explorer on the pkgdown site.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(patchwork)
  library(sf)
  library(rnaturalearth)
  library(ggvmap)
  library(gapminder)
})

# these cards are saved at 150 dpi -- tell showtext so IBM Plex renders at the
# right size (the shared theme defaults to 300 for the full-size gallery)
showtext::showtext_opts(dpi = 150)

# ---- shared data, computed once and recoloured per palette -----------------

# (1) Europe choropleth base (small scale = fast thumbnail)
eu <- ne_countries(scale = "small", returnclass = "sf") %>%
  filter(continent == "Europe" | name %in% c("Turkey", "Cyprus")) %>%
  filter(name != "Russia") %>%
  mutate(gdp_pc = ifelse(pop_est > 0, gdp_md * 1e6 / pop_est, NA_real_)) %>%
  st_transform(3035) %>%
  st_crop(st_bbox(c(xmin = 2.5e6, xmax = 6.0e6, ymin = 1.4e6, ymax = 5.4e6),
                  crs = st_crs(3035)))

# (2) Gapminder 2007 -- the full wealth-health curve, coloured per palette.
gap07 <- gapminder %>%
  filter(year == 2007) %>%
  mutate(continent = factor(continent,
                            levels = c("Africa", "Americas", "Asia",
                                       "Europe", "Oceania")))

# (3) Voronoi tessellation: compute polygons ONCE, recolour per palette
euc <- gapminder %>%
  filter(year == 2007, continent == "Europe") %>%
  slice_max(pop, n = 12) %>%
  mutate(country = as.character(country)) %>%
  arrange(desc(pop))
vm_df <- vm_as_df(voronoi_map(weights = euc$pop, labels = euc$country,
                              clip = clip_circle(), seed = 7))
vm_order <- unique(vm_df$label)

# (4) correlation heatmap (same structure as the gallery heatmap: clustered
#     cells with white borders), recoloured per palette
cm <- cor(mtcars)
cm <- cm[hclust(as.dist(1 - cm))$order, hclust(as.dist(1 - cm))$order]
cor_df <- as.data.frame(as.table(cm)) %>%
  setNames(c("x", "y", "r")) %>%
  mutate(x = factor(x, levels = rownames(cm)),
         y = factor(y, levels = rev(rownames(cm))))

# tiny, quiet panel theme with a small lowercase caption
mini <- function(cap, square = TRUE) {
  th <- theme_minimal(base_size = 10, base_family = "plexsans") +
    theme(plot.title = element_text(family = "plexsans", size = 9,
                                    colour = SUBTLE, margin = margin(b = 3)),
          axis.title = element_blank(), axis.text = element_blank(),
          panel.grid = element_blank(), axis.ticks = element_blank(),
          plot.margin = margin(2, 6, 2, 2),
          plot.background = element_rect(fill = "white", colour = NA))
  if (square) th <- th + theme(aspect.ratio = 1)
  list(labs(title = cap), th)
}

preview_card <- function(name) {
  cols <- ltc_palettes[[name]]
  n    <- length(cols)
  back <- ltc_info[[name]]
  ramp <- ltc_pal(name, type = "continuous")
  cont5 <- ltc_pal(name, n = 5, type = "continuous")   # 5 continent colours

  # choropleth map
  p_map <- ggplot(eu) +
    geom_sf(aes(fill = gdp_pc), colour = "white", linewidth = 0.12) +
    scale_fill_gradientn(colours = ramp, na.value = "#EDEDED", guide = "none") +
    coord_sf(expand = FALSE) + mini("map", square = FALSE) +
    theme(aspect.ratio = 1.15)

  # bubble: the full wealth-health curve, clean (theme_void)
  p_bub <- ggplot(gap07, aes(gdpPercap, lifeExp)) +
    geom_point(aes(size = pop, fill = continent), shape = 21,
               colour = "white", stroke = 0.35, alpha = 0.9) +
    scale_fill_manual(values = cont5, guide = "none") +
    scale_size_area(max_size = 9, guide = "none") +
    scale_x_log10() + mini("bubble", square = FALSE) +
    theme(aspect.ratio = 0.82)

  # ggvmap Voronoi treemap
  fills <- setNames(ltc_pal(name, n = length(vm_order), type = "continuous"),
                    vm_order)
  p_vor <- ggplot(vm_df, aes(x, y, group = cell, fill = label)) +
    geom_polygon(colour = "white", linewidth = 0.5) +
    scale_fill_manual(values = fills, guide = "none") +
    coord_fixed(expand = FALSE) + mini("voronoi", square = FALSE)

  # correlation heatmap (clustered cells with white borders, like the gallery)
  p_heat <- ggplot(cor_df, aes(x, y, fill = r)) +
    geom_tile(colour = "white", linewidth = 0.4) +
    scale_fill_gradientn(colours = ramp, guide = "none") +
    coord_fixed(expand = FALSE) + mini("heatmap", square = FALSE)

  # discrete barplot: one horizontal bar per palette colour
  bars <- tibble(cat = factor(seq_len(n), levels = rev(seq_len(n))),
                 val = seq(n, 1), col = cols)
  p_bar <- ggplot(bars, aes(val, cat, fill = col)) +
    geom_col(width = 0.78) +
    scale_fill_identity() +
    coord_cartesian(expand = FALSE) + mini("barplot", square = FALSE)

  # streamgraph: discrete series, centred silhouette (built without ggstream)
  k  <- min(n, 6)
  sx <- seq(1, 10, length.out = 60)
  sv <- vapply(seq_len(k), function(j)
    pmax(0.25, 2 + 1.4 * sin(sx / 1.5 + j) + 0.8 * cos(sx / 0.9 + j * 2)),
    numeric(length(sx)))
  soff <- -rowSums(sv) / 2
  stream <- do.call(rbind, lapply(seq_len(k), function(j) {
    base <- if (j > 1) rowSums(sv[, seq_len(j - 1), drop = FALSE]) else 0
    tibble(x = sx, ymin = soff + base, ymax = soff + base + sv[, j],
           series = factor(j))
  }))
  p_stream <- ggplot(stream, aes(x = x, ymin = ymin, ymax = ymax,
                                 fill = series)) +
    geom_ribbon() +
    scale_fill_manual(values = cols[seq_len(k)], guide = "none") +
    coord_cartesian(expand = FALSE) + mini("streamgraph", square = FALSE)

  (p_map | p_vor | p_heat) / (p_bub | p_bar | p_stream) +
    plot_annotation(
      title = name,
      theme = theme_void() +
        theme(plot.title = element_text(family = "plexmono", face = "bold",
                                        size = 17, colour = INK,
                                        margin = margin(b = 8)),
              plot.margin = margin(18, 18, 14, 18),
              plot.background = element_rect(fill = "white", colour = NA))
    )
}

dir.create(file.path("man", "figures", "previews"),
           showWarnings = FALSE, recursive = TRUE)

pal_names <- names(ltc_palettes)
if (exists("only") && length(only)) pal_names <- intersect(pal_names, only)

for (nm in pal_names) {
  ggsave(file.path("man", "figures", "previews", paste0(nm, ".png")),
         preview_card(nm), width = 9.8, height = 7.0, dpi = 150, bg = "white")
  message("  preview: ", nm)
}
message("Done: ", length(pal_names), " palette previews")
