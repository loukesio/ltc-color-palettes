# Shared style for the ltc gallery figures.
# Source this from each gallery script so every plot reads as one system:
# IBM Plex fonts (via showtext), white background, generous margins,
# quiet gridlines, and a consistent title / subtitle / caption block.
#
# Exposes:
#   ltc_palettes         named list of palette -> hex vector (from package source)
#   ltc_info             palette -> backstory (named character)
#   ltc_pal(name, n, type = "discrete")   convenience accessor
#   theme_ltc()          ggplot2 theme
#   INK, SUBTLE, GRID    shared text/line colours
#   gallery_save(plot, file, width, height)   write to man/figures/gallery

suppressPackageStartupMessages({
  library(ggplot2)
  library(sysfonts)
  library(showtext)
})

# --- palette source (single source of truth) -------------------------------
local({
  pkg <- new.env()
  sys.source(file.path("R", "ltc_functions.R"), envir = pkg)
  assign("ltc_palettes", pkg$palettes, envir = .GlobalEnv)
  assign("ltc_info",
         stats::setNames(pkg$info$bio, pkg$info$palette_name),
         envir = .GlobalEnv)
})

ltc_pal <- function(name, n = NULL, type = c("discrete", "continuous")) {
  type <- match.arg(type)
  pal <- ltc_palettes[[name]]
  if (is.null(pal)) stop("Unknown palette: ", name)
  if (is.null(n)) n <- length(pal)
  if (type == "continuous") grDevices::colorRampPalette(pal)(n) else pal[seq_len(n)]
}

# --- fonts -----------------------------------------------------------------
font_add_google("IBM Plex Sans", "plexsans")
font_add_google("IBM Plex Mono", "plexmono")
font_add_google("IBM Plex Sans", "plexsans_bold", bold.wt = 700)
showtext_auto()
showtext_opts(dpi = 300)

# --- shared colours --------------------------------------------------------
INK    <- "#1A1A1A"   # primary text
SUBTLE <- "#6B6B6B"   # subtitles, captions
GRID   <- "#E6E6E6"   # gridlines

# --- theme -----------------------------------------------------------------
theme_ltc <- function(base_size = 12) {
  theme_minimal(base_size = base_size, base_family = "plexsans") +
    theme(
      plot.title      = element_text(family = "plexsans", face = "bold",
                                     size = base_size * 1.6, colour = INK,
                                     margin = margin(b = 4)),
      plot.subtitle   = element_text(family = "plexsans", size = base_size * 1.02,
                                     colour = SUBTLE, margin = margin(b = 16),
                                     lineheight = 1.15),
      plot.caption    = element_text(family = "plexmono", size = base_size * 0.72,
                                     colour = SUBTLE, hjust = 0,
                                     margin = margin(t = 16)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title      = element_text(family = "plexsans", size = base_size * 0.9,
                                     colour = SUBTLE),
      axis.text       = element_text(family = "plexmono", size = base_size * 0.8,
                                     colour = SUBTLE),
      panel.grid.major = element_line(colour = GRID, linewidth = 0.35),
      panel.grid.minor = element_blank(),
      legend.title    = element_text(family = "plexsans", face = "bold",
                                     size = base_size * 0.85, colour = INK),
      legend.text     = element_text(family = "plexsans", size = base_size * 0.8,
                                     colour = SUBTLE),
      plot.background  = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = "white", colour = NA),
      plot.margin      = margin(22, 26, 18, 22)
    )
}

gallery_save <- function(plot, file, width = 9, height = 6.4) {
  path <- file.path("man", "figures", "gallery", file)
  ggsave(path, plot, width = width, height = height, dpi = 300, bg = "white")
  message("Wrote ", path, " (", width, " x ", height, " in)")
  invisible(path)
}
