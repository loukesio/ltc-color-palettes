# ggplot2 scales for the ltc palettes, in the style of scale_fill_viridis().

#' @title Build a Palette Function from an ltc Palette
#' @description Returns a function of `n` that gives `n` colours from the named
#' palette, which is the form ggplot2 scales expect. Like the rest of the
#' package, the name may be quoted, bare, or held in a variable.
#'
#' If more colours are asked for than the palette holds, the palette is
#' interpolated to that length rather than failing, so a scale never breaks on
#' a data set with more groups than expected.
#'
#' @param name Character or unquoted name. The name of the desired palette.
#' @param direction 1 keeps the palette order, -1 reverses it.
#' @return A function taking `n` and returning a character vector of `n` hex
#'   colour codes.
#' @examples
#' pal <- ltc_pal(maya)
#' pal(3)
#'
#' ltc_pal("expevo", direction = -1)(5)
#' @export
ltc_pal <- function(name, direction = 1) {
  palette_name <- resolve_palette_name(substitute(name), parent.frame())
  ltc_pal_impl(palette_name, direction)
}

# Same thing, but taking an already-resolved name. Shared by the scales below,
# which each resolve the name in their own caller's frame.
ltc_pal_impl <- function(palette_name, direction = 1) {
  pal <- palettes[[palette_name]]
  if (is.null(pal)) {
    stop("Palette '", palette_name,
         "' not found. Use names(palettes) to see available palettes.")
  }
  if (!direction %in% c(-1, 1)) {
    stop("`direction` must be 1 or -1.")
  }
  if (direction == -1) pal <- rev(pal)

  function(n) {
    if (n <= length(pal)) pal[seq_len(n)] else grDevices::colorRampPalette(pal)(n)
  }
}

#' @title ggplot2 Fill Scale from an ltc Palette
#' @description Colours the `fill` aesthetic with an ltc palette, the way
#' `scale_fill_viridis()` does. Set `discrete = FALSE` for a continuous scale.
#'
#' @param name Character or unquoted name. The name of the desired palette.
#' @param discrete `TRUE` for a discrete scale, `FALSE` for a continuous one.
#' @param direction 1 keeps the palette order, -1 reverses it.
#' @param ... Passed on to [ggplot2::discrete_scale()] when `discrete = TRUE`,
#'   or to [ggplot2::scale_fill_gradientn()] when `discrete = FALSE`.
#' @return A ggplot2 scale, to add to a plot.
#' @examples
#' library(ggplot2)
#'
#' # discrete
#' ggplot(mtcars, aes(factor(cyl), mpg, fill = factor(cyl))) +
#'   geom_boxplot() +
#'   scale_fill_ltc(maya)
#'
#' # continuous
#' ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster() +
#'   scale_fill_ltc(heatmap0, discrete = FALSE)
#' @export
scale_fill_ltc <- function(name, discrete = TRUE, direction = 1, ...) {
  palette_name <- resolve_palette_name(substitute(name), parent.frame())
  ltc_scale("fill", palette_name, discrete, direction, ...)
}

#' @title ggplot2 Colour Scale from an ltc Palette
#' @description Colours the `colour` aesthetic with an ltc palette, the way
#' `scale_colour_viridis()` does. Set `discrete = FALSE` for a continuous
#' scale. `scale_color_ltc()` is the same function under the US spelling.
#'
#' @inheritParams scale_fill_ltc
#' @param ... Passed on to [ggplot2::discrete_scale()] when `discrete = TRUE`,
#'   or to [ggplot2::scale_colour_gradientn()] when `discrete = FALSE`.
#' @return A ggplot2 scale, to add to a plot.
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
#'   geom_point(size = 3) +
#'   scale_colour_ltc(alger)
#' @export
scale_colour_ltc <- function(name, discrete = TRUE, direction = 1, ...) {
  palette_name <- resolve_palette_name(substitute(name), parent.frame())
  ltc_scale("colour", palette_name, discrete, direction, ...)
}

#' @rdname scale_colour_ltc
#' @export
scale_color_ltc <- function(name, discrete = TRUE, direction = 1, ...) {
  palette_name <- resolve_palette_name(substitute(name), parent.frame())
  ltc_scale("colour", palette_name, discrete, direction, ...)
}

# Shared body of the scales: a discrete scale gets the palette function, a
# continuous one gets the full ramp handed to gradientn.
ltc_scale <- function(aesthetic, palette_name, discrete, direction, ...) {
  pal_fun <- ltc_pal_impl(palette_name, direction)
  if (isTRUE(discrete)) {
    ggplot2::discrete_scale(aesthetic, palette = pal_fun, ...)
  } else {
    cols <- pal_fun(length(palettes[[palette_name]]))
    if (aesthetic == "fill") {
      ggplot2::scale_fill_gradientn(colours = cols, ...)
    } else {
      ggplot2::scale_colour_gradientn(colours = cols, ...)
    }
  }
}
