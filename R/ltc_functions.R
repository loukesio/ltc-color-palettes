#' ltc: A Collection of Art-inspired Colour Palettes
#'
#' This package provides a collection of color palettes inspired by
#' art, nature, and personal preferences. Each palette has a backstory,
#' providing context and meaning to the colors.
#'
#' @name ltc

#' @title List of colour palettes
#' @description A list containing predefined colour palettes with artistic backstories.
#' @export
palettes <- list(
  paloma = c("#83AF9B","#C8C8A9","#f8da8a","#f7bf95","#fe8ca1"),
  maya = c("#3d5a80","#98c1d9","#e0fbfc","#ee6c4d","#293241"),
  dora = c("#52777A","#542437","#C02942","#D95B43","#ECD078"),
  ploen = c("#3F5671","#83A1C3","#CEB5C8","#FAC898","#B17776"),
  olga = c("#c9e3c2","#8bc8cb","#eccd80","#f5ab70","#9c87a1"),
  mterese = c("#f7ddaa","#fac3ad","#f897a1","#9298BA","#9cbeed"),
  gaby = c("#fceaab","#f1a890","#a8c4cc","#82A0C2","#85496F"),
  franscoise = c("#5980B1","#b96a8d","#A55062","#E05256","#E9A986"),
  fernande = c("#ff7676","#F9D662","#7cab7d","#75B7D1"),
  sylvie = c("#E8B961","#E88170","#C6BDE8","#5DB7C4","#FD95BC"),
  expevo = c("#FC4E07","#E7B800","#00AFBB","#8B4769","#1d457f","#808080"),
  minou = c("#00798c","#d1495b","#edae49","#66a182","#2e4057","#8d96a3"),
  kiss = c("#FF7C7E","#FEC300","#9E3F71","#31BCBA","#E20035"),
  hat = c('#efb306','#eb990c','#e8351e','#cd023d','#852f88','#4e54ac','#0f8096','#7db954','#17a769','#000000'),
  reading = c("#EFBC68","#919F89","#EDBDAE","#57717C","#5F97A4","#CAEAC8","#95A1AE","#C8CFD6"),
  alger = c("#000000","#1A5B5B","#ACC8BE","#F4AB5C","#D1422F"),
  trio1 = c("#0E7175","#FD7901","#C35BCA"),
  trio2 = c("#89973D","#E8B92F","#A45E41"),
  trio3 = c("#E69F00", "#56B4E9", "#009E73"),
  trio4 = c("#94475E","#364C54","#E5A11F"),
  heatmap0 = c("#001219","#005F73","#0A9396","#94D2BD","#E9D8A6","#EE9B00","#CA6702","#AE2012","#9B2226"),
  pantone23 = c("#7A92A5","#1F2C43","#FFB000","#842c48","#46483d"),
  remains = c("#69326E", "#EEEDC0", "#FF6D1F", "#EED455"),
  midnight = c("#16232A", "#FF5B04", "#075056", "#E4EEF0"),
  lincoln = c("#EEE9DF", "#C9C1B1", "#2C3B4D", "#FFB162", "#A35139", "#1B2632"),
  luminaries = c("#FF5B04", "#075056", "#233038", "#FDF6E3", "#F4D47C", "#D3DBDD"),
  seafarer = c("#013D5A", "#FCF3E3", "#BDD3CE", "#708C69", "#E4A25B"),
  shuggie = c("#5B5F8D", "#9BB29E", "#DA6B51", "#F1DCBA", "#484149"),
  heatmap1 = c("#4d7799", "#7fa4c4", "#c5c8d4", "#d48e95", "#b5515b"),
  heatmap2 = c("#ca0020", "#f4a582", "#f7f7f7", "#92c5de", "#0571b0"),
  heatmap3 = c("#d7191c", "#fdae61", "#ffffbf", "#abd9e9", "#2c7bb6")
)

#' @title Select a Colour Palette from ltc
#' @description This function provides the desired colour palette by name.
#' You can call it with or without quotes: ltc(paloma) or ltc("paloma")
#'
#' @param name Character or unquoted name. The name of the desired palette.
#' @param n Integer. The number of colors you want from the palette.
#' If omitted, it uses all colors from the palette.
#' @param type The type of palette. Either "discrete" or "continuous".
#' @return A vector of hex color codes with class "ltc"
#' @examples
#' # Load a palette (with or without quotes)
#' ltc(paloma)
#' ltc("maya")
#'
#' # Select first 3 colors
#' ltc(maya, n = 3)
#'
#' # Generate continuous palette
#' ltc(remains, n = 10, type = "continuous")
#' @export
ltc <- function(name, n, type = c("discrete", "continuous")) {
  type <- match.arg(type)

  # Capture the name argument (allows both quoted and unquoted)
  name_expr <- substitute(name)

  # Convert to character
  if (is.character(name_expr)) {
    palette_name <- name_expr
  } else {
    palette_name <- as.character(name_expr)
  }

  pal <- palettes[[palette_name]]
  if (is.null(pal)) {
    stop("Palette '", palette_name, "' not found. Use names(palettes) to see available palettes.")
  }

  if (missing(n)) {
    n <- length(pal)
  }

  if (type == "discrete" && n > length(pal)) {
    stop("Number of requested colors greater than what palette can offer")
  }

  out <- switch(type,
                continuous = grDevices::colorRampPalette(pal)(n),
                discrete = pal[1:n]
  )

  structure(out, class = "ltc", name = palette_name)
}

#' @title Print Method for ltc Objects
#' @description Custom print method that displays the palette name followed
#' by hex color codes with actual colors visible in the console.
#' @param x An ltc palette object
#' @param ... Additional arguments (currently unused)
#' @return Invisibly returns the palette object
#' @export
print.ltc <- function(x, ...) {
  palette_name <- attr(x, "name")

  # Check if crayon is available for colored output
  has_crayon <- requireNamespace("crayon", quietly = TRUE)

  cat(palette_name, "\n", sep = "")

  if (has_crayon && crayon::has_color()) {
    # Print with actual colors as background with black squares
    for (color in x) {
      cat(crayon::make_style(color, bg = TRUE)("  "), " ", color, "\n", sep = "")
    }
  } else {
    # Fallback: just print hex codes
    cat(paste(x, collapse = "\n"), "\n", sep = "")
  }

  invisible(x)
}

#' @title Information about the Colour Palettes
#' @description This dataframe contains the backstory or inspiration behind each color palette.
#' @export
info <- data.frame(
  palette_name = c("paloma",
                   "maya",
                   "dora",
                   "ploen",
                   "olga",
                   "mterese",
                   "gaby",
                   "franscoise",
                   "fernande",
                   "sylvie",
                   "expevo",
                   "minou",
                   "kiss",
                   "hat",
                   "reading",
                   "alger",
                   "trio1",
                   "trio2",
                   "trio3",
                   "trio4",
                   "heatmap0",
                   "pantone23",
                   "remains",
                   "midnight",
                   "lincoln",
                   "luminaries",
                   "seafarer",
                   "shuggie",
                   "heatmap1",
                   "heatmap2",
                   "heatmap3"),
  bio = c("Daughter of Francoise Gilot and Pablo Picasso",
          "Daughter of Marie-Therese Walter and Pablo Ruiz Picasso",
          "French photographer, painter, and poet",
          "A beautiful village in Northern Germany",
          "Olga Khokhlova was a Russian ballet dancer",
          "Marie-Therese Walter was a French model and mother of Maya",
          "Gabrielle Depeyre Lespinasse was a French dancer",
          "Francoise Gilot was a significant French painter",
          "Fernande was a French model and artist",
          "Sylvette David is a French artist and model",
          "A palette that is often being used by biologists",
          "Minou was Picasso's favorite cat",
          "Inspired by The Kiss Picasso 1925",
          "Inspired by Woman in Hat Picasso 1937",
          "Inspired by Two Girls Reading Picasso 1934",
          "Inspired by Les femmes d'Alger Picasso 1955",
          "A discrete color palette to visualize 3 variables",
          "A discrete color palette to visualize 3 variables",
          "A discrete color palette to visualize 3 variables",
          "A discrete color palette to visualize 3 variables",
          "A diverging color palette suitable for heatmaps",
          "Soft Chaos was released by Pantone in Summer 23",
          "Inspired by The Remains of the Day by Kazuo Ishiguro (Booker Prize 1989)",
          "Inspired by Midnight's Children by Salman Rushdie (Booker Prize 1981)",
          "Inspired by Lincoln in the Bardo by George Saunders (Booker Prize 2017)",
          "Inspired by The Luminaries by Eleanor Catton (Booker Prize 2013)",
          "Inspired by The Old Man and the Sea theme - maritime literary palette",
          "Inspired by Shuggie Bain by Douglas Stuart (Booker Prize 2020)",
          "Blue and Red diverging palette 7 - ideal for heatmaps and expression data",
          "Blue and Red diverging palette 8 - classic diverging scheme",
          "Blue and Red diverging palette 9 - warm-cool diverging palette"),
  stringsAsFactors = FALSE
)

#' @title Plot a Colour Palette
#' @description Visualizes a selected colour palette as a bar of colours.
#' @param x An ltc palette object
#' @param ... Additional arguments (currently unused).
#' @return A ggplot2 object showing the selected colours.
#' @examples
#' \donttest{
#' # Create and plot a palette
#' pal <- ltc(paloma)
#' plot(pal)
#' }
#' @importFrom ggplot2 ggplot aes geom_tile theme_void labs theme element_text geom_text
#' @importFrom dplyr filter %>%
#' @export
plot.ltc <- function(x, ...) {

  chromata <- x

  # Get palette info
  palette_name <- attr(chromata, "name")

  if (is.null(palette_name)) {
    stop("This object doesn't have a palette name attribute")
  }

  info2 <- info %>%
    dplyr::filter(palette_name == attr(chromata, "name"))

  if (nrow(info2) == 0) {
    stop("Palette information not found for: ", palette_name)
  }

  n <- length(chromata)
  df <- data.frame(xvals = 1:n, yvals = rep(1, n), text = chromata[1:n], stringsAsFactors = FALSE)

  ggplot2::ggplot(df, ggplot2::aes(x = xvals, y = yvals)) +
    ggplot2::geom_tile(fill = chromata,
                       colour = "white",
                       linewidth = 1) +
    ggplot2::geom_text(ggplot2::aes(label = text), color = "#333333", nudge_y = -0.53) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, face = "italic"),
                   plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 10),
                   legend.position = "none") +
    ggplot2::labs(title = info2$palette_name, subtitle = info2$bio)
}

#' @title Plot a Colour Palette as a Bird
#' @description Visualizes a selected colour palette in the form of a bird drawing.
#' Requires at least 5 colors in the palette.
#'
#' @param chrom An ltc palette object
#' @return A ggplot2 object showing a bird drawing using the selected colours.
#' @examples
#' \donttest{
#' # Create a bird visualization
#' pal <- ltc(paloma)
#' bird(pal)
#' }
#' @importFrom ggplot2 ggplot theme_void labs theme aes geom_rect element_text
#' @importFrom ggforce geom_shape
#' @importFrom dplyr filter %>%
#' @export
bird <- function(chrom){

  # Check if it's an ltc object
  if (!inherits(chrom, "ltc")) {
    stop("Input must be an ltc palette object. Use ltc() to create one.")
  }

  # Check if palette has enough colors
  if (length(chrom) < 5) {
    stop("Bird visualization requires at least 5 colors. Current palette has ",
         length(chrom), " colors.")
  }

  data <- data.frame(x1 = 0, x2 = 5, y1 = -5, y2 = 5, x3 = 4.5, x4 = 5.5, y3 = 0, y4 = 12)

  shape1 <- data.frame(
    x = c(2, 3, 3, 2),
    y = c(0, 2, 8, 10)
  )
  shape2 <- data.frame(
    x2 = c(2, 2.5, 2.5, 2),
    y2 = c(1, 3, -2, -4)
  )
  shape3 <- data.frame(
    x3 = c(3, 3.22, 3),
    y3 = c(8, 8, 7.33)
  )
  shape4 <- data.frame(
    x4 = c(1.99, 2.5, 3.01, 3.01, 2, 2),
    y4 = c(5, 6.5, 5, 2, -0.01, 1)
  )

  palette_name <- attr(chrom, "name")

  if (is.null(palette_name)) {
    stop("This object doesn't have a palette name attribute")
  }

  info2 <- info %>%
    dplyr::filter(palette_name == attr(chrom, "name"))

  ggplot2::ggplot() +
    ggplot2::geom_rect(data = data,
                       mapping = ggplot2::aes(xmin = x1, xmax = x2, ymin = y1, ymax = y4),
                       fill = chrom[1], color = "NA") +
    ggforce::geom_shape(data = shape1, ggplot2::aes(x = x, y = y), fill = chrom[2]) +
    ggforce::geom_shape(data = shape3, ggplot2::aes(x = x3, y = y3), fill = chrom[3]) +
    ggforce::geom_shape(data = shape4, ggplot2::aes(x = x4, y = y4), fill = chrom[4]) +
    ggforce::geom_shape(data = shape2, ggplot2::aes(x = x2, y = y2), fill = chrom[5]) +
    ggplot2::theme_void() +
    ggplot2::labs(title = info2$palette_name, subtitle = info2$bio) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, face = "italic"),
                   plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 10))
}

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
