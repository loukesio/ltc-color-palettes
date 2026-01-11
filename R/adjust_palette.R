#' @title Adjust Lightness of Palette Colors
#' @description Darken or lighten an entire palette or specific colors within it.
#' Uses the colorspace package for perceptually uniform adjustments.
#'
#' @param palette_name Character or unquoted name. Name of the ltc palette to adjust.
#' @param amount Numeric. Amount to adjust lightness (-100 to 100).
#'   Negative values darken, positive values lighten. Default is 0 (no change).
#' @param which Integer vector. Which colors to adjust (e.g., c(1, 3) for 1st and 3rd).
#'   If NULL (default), adjusts all colors.
#' @return A vector of adjusted hex color codes with class "ltc"
#' @examples
#' \donttest{
#' # Darken entire palette
#' adjust_ltc(alger, amount = -20)
#'
#' # Lighten entire palette
#' adjust_ltc("maya", amount = 30)
#'
#' # Darken only specific colors
#' adjust_ltc(remains, amount = -25, which = c(2, 4))
#' }
#' @importFrom colorspace darken lighten
#' @export
adjust_ltc <- function(palette_name, amount = 0, which = NULL) {

  if (!requireNamespace("colorspace", quietly = TRUE)) {
    stop("Package 'colorspace' is required. Install it with: install.packages('colorspace')")
  }

  # Handle unquoted names
  name_expr <- substitute(palette_name)
  if (is.character(name_expr)) {
    pal_name <- name_expr
  } else {
    pal_name <- as.character(name_expr)
  }

  pal <- palettes[[pal_name]]
  if (is.null(pal)) {
    stop("Palette '", pal_name, "' not found. Use names(palettes) to see available palettes.")
  }

  if (!is.numeric(amount) || length(amount) != 1) {
    stop("'amount' must be a single numeric value between -100 and 100")
  }
  if (amount < -100 || amount > 100) {
    warning("'amount' should be between -100 and 100. Values outside this range may produce unexpected results.")
  }

  adjusted_pal <- pal

  if (is.null(which)) {
    which <- seq_along(pal)
  } else {
    if (!is.numeric(which) || any(which < 1) || any(which > length(pal))) {
      stop("'which' must contain valid color positions (1 to ", length(pal), ")")
    }
    which <- as.integer(which)
  }

  if (amount < 0) {
    adjusted_pal[which] <- colorspace::darken(pal[which], amount = abs(amount)/100)
  } else if (amount > 0) {
    adjusted_pal[which] <- colorspace::lighten(pal[which], amount = amount/100)
  }

  structure(adjusted_pal,
            class = "ltc",
            name = paste0(pal_name, "_adj", amount))
}

#' @title Create Custom Palette with Individual Color Adjustments
#' @description Apply different lightness adjustments to each color in a palette.
#'
#' @param palette_name Character or unquoted name. Name of the ltc palette.
#' @param adjustments Numeric vector. Lightness adjustments for each color (-100 to 100).
#'   Length must match the palette length.
#' @return A vector of adjusted hex color codes with class "ltc"
#' @examples
#' \donttest{
#' # Different adjustment for each color
#' custom_adjust_ltc(remains, c(-30, 0, 40, 0))
#'
#' # Create gradient effect
#' custom_adjust_ltc("maya", c(-40, -20, 0, 20, 40))
#' }
#' @importFrom colorspace darken lighten
#' @export
custom_adjust_ltc <- function(palette_name, adjustments) {

  if (!requireNamespace("colorspace", quietly = TRUE)) {
    stop("Package 'colorspace' is required.")
  }

  # Handle unquoted names
  name_expr <- substitute(palette_name)
  if (is.character(name_expr)) {
    pal_name <- name_expr
  } else {
    pal_name <- as.character(name_expr)
  }

  pal <- palettes[[pal_name]]
  if (is.null(pal)) {
    stop("Palette '", pal_name, "' not found.")
  }

  if (length(adjustments) != length(pal)) {
    stop("'adjustments' must have same length as palette (", length(pal), " colors)")
  }
  if (!is.numeric(adjustments)) {
    stop("'adjustments' must be numeric")
  }

  adjusted_pal <- pal
  for (i in seq_along(pal)) {
    if (adjustments[i] < 0) {
      adjusted_pal[i] <- colorspace::darken(pal[i], amount = abs(adjustments[i])/100)
    } else if (adjustments[i] > 0) {
      adjusted_pal[i] <- colorspace::lighten(pal[i], amount = adjustments[i]/100)
    }
  }

  structure(adjusted_pal,
            class = "ltc",
            name = paste0(pal_name, "_custom"))
}

#' @title Desaturate Palette Colors
#' @description Reduce color saturation (make colors more gray).
#'
#' @param palette_name Character or unquoted name. Name of the ltc palette.
#' @param amount Numeric. Desaturation amount (0 to 1).
#'   0 = no change, 1 = completely gray.
#' @param which Integer vector. Which colors to desaturate.
#'   If NULL (default), affects all colors.
#' @return A vector of desaturated hex color codes with class "ltc"
#' @examples
#' \donttest{
#' # Desaturate entire palette
#' desaturate_ltc(luminaries, amount = 0.5)
#'
#' # Desaturate only specific colors
#' desaturate_ltc("heatmap2", amount = 0.7, which = c(1, 2))
#' }
#' @importFrom colorspace desaturate
#' @export
desaturate_ltc <- function(palette_name, amount = 0.5, which = NULL) {

  if (!requireNamespace("colorspace", quietly = TRUE)) {
    stop("Package 'colorspace' is required.")
  }

  # Handle unquoted names
  name_expr <- substitute(palette_name)
  if (is.character(name_expr)) {
    pal_name <- name_expr
  } else {
    pal_name <- as.character(name_expr)
  }

  pal <- palettes[[pal_name]]
  if (is.null(pal)) {
    stop("Palette '", pal_name, "' not found.")
  }

  if (amount < 0 || amount > 1) {
    stop("'amount' must be between 0 and 1")
  }

  adjusted_pal <- pal

  if (is.null(which)) {
    which <- seq_along(pal)
  }

  adjusted_pal[which] <- colorspace::desaturate(pal[which], amount = amount)

  structure(adjusted_pal,
            class = "ltc",
            name = paste0(pal_name, "_desat"))
}
