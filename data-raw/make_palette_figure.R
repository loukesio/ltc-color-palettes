# Generate the all-palettes overview figure for the README.
# Reads palette definitions and descriptions straight from the package source,
# so re-running this script after adding a palette updates the figure
# automatically (a new palette only needs a category assignment below).
#
# Output: man/figures/all_palettes.png
# Fonts:  IBM Plex Mono / IBM Plex Sans (fetched from Google Fonts via showtext)

pkg <- new.env()
sys.source(file.path("R", "ltc_functions.R"), envir = pkg)
palettes <- pkg$palettes
descriptions <- stats::setNames(pkg$info$bio, pkg$info$palette_name)

groups <- list(
  "Large (>5) Palettes"    = c("hat", "reading", "luminaries", "lincoln", "minou",
                               "expevo", "casa_natal"),
  "Heatmap Theme Palettes" = c("heatmap0", "heatmap1", "heatmap2", "heatmap3"),
  "Dark Theme Palettes"    = c("dora", "kiss", "franscoise", "alger", "pantone23",
                               "maya", "shuggie", "midnight"),
  "Pastel Theme Palettes"  = c("paloma", "olga", "mterese", "gaby", "ploen",
                               "seafarer", "sylvie", "fernande", "remains"),
  "Trio Palettes"          = c("trio1", "trio2", "trio3", "trio4")
)

missing_pal <- setdiff(unlist(groups), names(palettes))
if (length(missing_pal) > 0) {
  stop("Grouped palettes not found in package: ", paste(missing_pal, collapse = ", "))
}
leftover <- setdiff(names(palettes), unlist(groups))
if (length(leftover) > 0) {
  warning("Palettes without a category, adding under 'Other Palettes': ",
          paste(leftover, collapse = ", "))
  groups[["Other Palettes"]] <- leftover
}

sysfonts::font_add_google("IBM Plex Mono", "plexmono")
sysfonts::font_add_google("IBM Plex Sans", "plexsans")
showtext::showtext_auto()

res <- 150
showtext::showtext_opts(dpi = res)

# --- geometry (px) ---------------------------------------------------------
W          <- 1200   # figure width
margin_y   <- 70     # top/bottom margin
title_h    <- 120    # vertical space for a section title block
name_h     <- 30     # palette name line
desc_h     <- 26     # description line
strip_h    <- 52     # swatch strip height
hex_h      <- 26     # hex label line
row_gap    <- 46     # gap between palettes
sw         <- 88     # width of one swatch
margin_x   <- 60     # left margin all elements align to

row_h <- name_h + desc_h + strip_h + hex_h
n_pal <- length(unlist(groups))
H <- 2 * margin_y +
  length(groups) * title_h +
  n_pal * row_h +
  (n_pal - length(groups)) * row_gap

grDevices::png(file.path("man", "figures", "all_palettes.png"),
               width = W, height = H, res = res, bg = "white")
graphics::par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
graphics::plot(NULL, xlim = c(0, W), ylim = c(H, 0), asp = 1,
               axes = FALSE, xlab = "", ylab = "")

y <- margin_y
for (section in names(groups)) {
  graphics::text(W / 2, y + title_h * 0.45, section,
                 family = "plexmono", font = 2, cex = 1.55, col = "#000000")
  y <- y + title_h

  for (pal_name in groups[[section]]) {
    cols <- palettes[[pal_name]]
    n <- length(cols)

    graphics::text(margin_x, y + name_h * 0.5, pal_name, adj = 0,
                   family = "plexmono", font = 2, cex = 0.95, col = "#000000")
    y <- y + name_h

    desc <- descriptions[[pal_name]]
    if (!is.null(desc) && !is.na(desc)) {
      graphics::text(margin_x, y + desc_h * 0.4, desc, adj = 0,
                     family = "plexsans", cex = 0.62, col = "#8C8C8C")
    }
    y <- y + desc_h

    x0 <- margin_x
    graphics::rect(x0 + (seq_len(n) - 1) * sw, y + strip_h,
                   x0 + seq_len(n) * sw, y,
                   col = cols, border = NA)
    y <- y + strip_h

    graphics::text(x0 + (seq_len(n) - 0.5) * sw, y + hex_h * 0.55,
                   toupper(cols),
                   family = "plexmono", cex = 0.48, col = "#333333")
    y <- y + hex_h + row_gap
  }
  y <- y - row_gap  # section gap is provided by the next title block
}

grDevices::dev.off()
message("Wrote man/figures/all_palettes.png (", W, " x ", H, " px, ",
        n_pal, " palettes)")
