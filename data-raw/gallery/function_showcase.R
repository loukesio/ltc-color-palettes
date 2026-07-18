# Generate README figures that showcase the ltc helper functions:
#   adjust_ltc() / desaturate_ltc()  -> ReadMEFigures/adjust_showcase.png
#   ltc_cvd()                        -> ReadMEFigures/cvd_showcase.png
# Colours are computed with the same colorspace transforms the functions use.

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(ggplot2)
  library(colorspace)
})
showtext::showtext_opts(dpi = 150)

draw_rows <- function(rows, title, subtitle, file, height) {
  labs <- names(rows)
  df <- do.call(rbind, lapply(seq_along(rows), function(i)
    data.frame(row = factor(labs[i], levels = rev(labs)),
               x = seq_along(rows[[i]]), fill = rows[[i]])))
  lum <- colSums(grDevices::col2rgb(df$fill) * c(0.299, 0.587, 0.114))
  df$txt <- ifelse(lum > 150, INK, "white")

  p <- ggplot(df, aes(x, row, fill = fill)) +
    geom_tile(colour = "white", linewidth = 1.8) +
    geom_text(aes(label = toupper(fill)), colour = df$txt,
              family = "plexmono", size = 2.5) +
    scale_fill_identity() +
    coord_cartesian(expand = FALSE) +
    labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    theme_ltc(base_size = 12) +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_text(family = "plexmono", colour = INK, hjust = 1),
          panel.grid = element_blank())
  ggsave(file, p, width = 8.6, height = height, dpi = 150, bg = "white")
  message("Wrote ", file)
}

pal <- ltc_palettes[["maya"]]

draw_rows(
  list(
    "original"          = pal,
    "adjust_ltc(-30)"   = colorspace::darken(pal, 0.30),
    "adjust_ltc(+30)"   = colorspace::lighten(pal, 0.30),
    "desaturate_ltc(.6)" = colorspace::desaturate(pal, 0.6)
  ),
  title    = "Adjusting a palette",
  subtitle = "The 'maya' palette darkened, lightened and desaturated",
  file     = file.path("ReadMEFigures", "adjust_showcase.png"),
  height   = 3.6
)

draw_rows(
  list(
    "Normal"       = pal,
    "Deuteranopia" = colorspace::deutan(pal),
    "Protanopia"   = colorspace::protan(pal),
    "Tritanopia"   = colorspace::tritan(pal)
  ),
  title    = "Colour-vision check with ltc_cvd()",
  subtitle = "How 'maya' looks under the three main types of colour blindness",
  file     = file.path("ReadMEFigures", "cvd_showcase.png"),
  height   = 3.6
)
