#' @title Preview a Palette under Colour Vision Deficiency (CVD)
#' @description Simulates how an `ltc` palette appears to viewers with the three
#' main types of colour vision deficiency (colour blindness) and shows the
#' result as rows of swatches. Useful for checking whether a palette stays
#' distinguishable for colour-blind readers.
#'
#' The simulation uses \pkg{colorspace}: deuteranopia (green-weak, the most
#' common), protanopia (red-weak) and tritanopia (blue-weak).
#'
#' @param name Character or unquoted palette name (e.g. `dora` or `"dora"`),
#'   or a character vector of hex colours.
#' @param severity Numeric in `[0, 1]`. Strength of the deficiency, where `1`
#'   is the full dichromatic simulation (the default) and lower values give
#'   milder anomalous-trichromacy simulations.
#' @param labels Logical. If `TRUE` (default) the hex codes are printed on the
#'   swatches.
#' @return A \pkg{ggplot2} object: one row of swatches per vision type
#'   (Normal, Deuteranopia, Protanopia, Tritanopia).
#' @examples
#' \donttest{
#' ltc_cvd(dora)
#' ltc_cvd("expevo", severity = 0.6)
#' }
#' @importFrom colorspace deutan protan tritan
#' @importFrom ggplot2 ggplot aes geom_tile geom_text scale_fill_identity
#'   coord_cartesian labs theme_minimal theme element_text element_blank margin
#' @export
ltc_cvd <- function(name, severity = 1, labels = TRUE) {

  # resolve the palette: a hex vector, or a palette name (quoted/unquoted)
  name_expr <- substitute(name)
  if (is.character(name) && length(name) > 1) {
    pal <- name
    pal_name <- "palette"
  } else {
    pal_name <- if (is.character(name)) name else as.character(name_expr)
    pal <- palettes[[pal_name]]
    if (is.null(pal)) {
      stop("Palette '", pal_name,
           "' not found. Use names(palettes) to see available palettes.")
    }
  }

  if (severity < 0 || severity > 1) {
    stop("`severity` must be between 0 and 1.")
  }

  vision <- list(
    Normal        = pal,
    Deuteranopia  = colorspace::deutan(pal, severity = severity),
    Protanopia    = colorspace::protan(pal, severity = severity),
    Tritanopia    = colorspace::tritan(pal, severity = severity)
  )
  types <- names(vision)

  df <- data.frame(
    type  = factor(rep(types, each = length(pal)), levels = rev(types)),
    x     = rep(seq_along(pal), times = length(vision)),
    fill  = unlist(vision, use.names = FALSE),
    stringsAsFactors = FALSE
  )

  # readable label colour per swatch (dark text on light fills, and vice versa)
  lum <- (grDevices::col2rgb(df$fill)["red", ] * 0.299 +
          grDevices::col2rgb(df$fill)["green", ] * 0.587 +
          grDevices::col2rgb(df$fill)["blue", ] * 0.114)
  df$txt <- ifelse(lum > 150, "#1A1A1A", "#FFFFFF")

  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = type, fill = fill)) +
    ggplot2::geom_tile(colour = "white", linewidth = 1.2)

  if (labels) {
    p <- p + ggplot2::geom_text(ggplot2::aes(label = toupper(fill)),
                                colour = df$txt, size = 2.6)
  }

  p +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_cartesian(expand = FALSE) +
    ggplot2::labs(title = pal_name,
                  subtitle = "Colour vision deficiency simulation",
                  x = NULL, y = NULL) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      plot.subtitle = ggplot2::element_text(colour = "#6B6B6B"),
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(hjust = 1),
      panel.grid = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(12, 14, 12, 12)
    )
}

# quiet R CMD check about columns referenced via ggplot2 aes()
utils::globalVariables(c("x", "type", "fill"))
