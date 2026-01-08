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
    maya=c("#3d5a80","#98c1d9","#e0fbfc","#ee6c4d","#293241"),
    dora = c("#52777A","#542437","#C02942","#D95B43","#ECD078"),
    ploen = c("#3F5671","#83A1C3","#CEB5C8","#FAC898","#B17776"),
    olga=c("#c9e3c2","#8bc8cb","#eccd80","#f5ab70","#9c87a1"),
    mterese=c("#f7ddaa","#fac3ad","#f897a1","#9298BA","#9cbeed"),
    gaby=c("#fceaab","#f1a890","#a8c4cc","#82A0C2","#85496F"),
    franscoise=c("#5980B1","#b96a8d","#A55062","#E05256","#E9A986"),
    fernande=c("#ff7676","#F9D662","#7cab7d","#75B7D1"),
    sylvie=c("#E8B961","#E88170","#C6BDE8","#5DB7C4","#FD95BC"),
    crbhits=c("#CBC106","#27993C","#1C6838","#8EBCB5","#389CA7","#4D83AB","#CB7B26","#BF565D","#9E163C"),
    expevo=c("#FC4E07","#E7B800","#00AFBB","#8B4769","#1d457f","#808080"),
    minou=c("#00798c","#d1495b","#edae49","#66a182","#2e4057","#8d96a3"),
    kiss=c("#FF7C7E","#FEC300","#9E3F71","#31BCBA","#E20035"),
    hat=c('#efb306','#eb990c','#e8351e','#cd023d','#852f88','#4e54ac','#0f8096','#7db954','#17a769','#000000'),
    reading=c("#EFBC68","#919F89","#EDBDAE","#57717C","#5F97A4","#CAEAC8","#95A1AE","#C8CFD6"),
    ten_colors=c('#efb306','#eb990c','#e8351e','#cd023d','#852f88', '#4e54ac','#0f8096', '#7db954','#17a769','#000000'),
    alger=c("#000000","#1A5B5B","#ACC8BE","#F4AB5C","#D1422F"),
    trio1=c("#0E7175","#FD7901","#C35BCA"),
    trio2=c("#89973D","#E8B92F","#A45E41"),
    trio3=c("#E69F00", "#56B4E9", "#009E73"),
    trio4=c("#94475E","#364C54","#E5A11F"),
    heatmap=c("#001219","#005F73","#0A9396","#94D2BD","#E9D8A6","#EE9B00","#CA6702","#AE2012","#9B2226"),
    pantone23=c("#7A92A5","#1F2C43","#FFB000","#842c48","#46483d")
)

#' @title Select a Colour Palette from ltc
#' @description This function provides the desired colour palette by name.
#'
#' @param name Character. The name of the desired palette.
#' @param n Integer. The number of colors you want from the palette.
#' If omitted, it uses all colors from the palette.
#' @param type The type of palette. Either "discrete" or "continuous".
#' @return A vector of hex color codes
#' @examples
#' \dontrun{
#' ltc("paloma")
#' ltc("dora", n = 3)
#'}
#' @export


ltc <- function(name, n, type = c("discrete", "continuous")) {
  type <- match.arg(type)

  pal <- palettes[[name]]
  if (is.null(pal))
    stop("We do not have a palette with this name.")

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

 structure(out, class = "palette", name = name)
}

#' @title Information about the Colour Palettes
#' @description This dataframe contains the backstory or inspiration behind each color palette.
#' @export
info <- data.frame(palette_name=c("paloma",
                                  "maya",
                                  "dora",
                                  "ploen",
                                  "olga",
                                  "mterese",
                                  "gaby",
                                  "franscoise",
                                  "fernande",
                                  "sylvie",
                                  "crbhits",
                                  "expevo",
                                  "minou",
                                  "kiss",
                                  "hat",
                                  "reading",
                                  "ten_colors",
                                  "alger",
                                  "trio1",
                                  "trio2",
                                  "trio3",
                                  "trio4",
                                  "heatmap",
                                  "pantone23"),
                   bio=c("Daughter of Francoise Gillot and Pablo Picasoo",
                         c("Daughter of  Marie-Therese Walte and Pablo Ruiz Picasso"),
                         c("French photographer, painter, and poet"),
                         c("A beautiful village in Northern Germany"),
                         c("Olga Khokhlova was a Russian ballet dancer"),
                         c("Marie-Therese Walter was a French model and mother of Maya"),
                         c("Gabrielle Depeyre Lespinasse was a french dancer"),
                         c("Francoise Gilot was a significant French painter"),
                         c("Fernande was a French model and artist"),
                         c("Sylvette David is a French artist and model"),
                         c("CRBHits is a R package developed by K Ullrich"),
                         c("A palette that is often being used by biologists"),
                         c("Minou was Picasso's favorite cat"),
                         c("Inspired by The Kiss Picasso 1925"),
                         c("Inspired by Woman in hat Picasso 1937"),
                         c("Inspired by Two Girls Reading Picasso 1934"),
                         c("The Ten different colors offers variety without overwhelming the design"),
                         c("Inspired by Les femmes d Alger Picasso 1955"),
                         c("A discrete color palette to visualise 3 variables"),
                         c("A discrete color palette to visualise 3 variables"),
                         c("A discrete color palette to visualise 3 variables"),
                         c("A discrete color palette to visualise 3 variables"),
                         c("A diverging color palette suitable for heatmaps"),
                         c("Soft Chaos was realeased by Pantone in Summer 23 ")
                      ))

#' @title Plot a Colour Palette
#' @description Visualizes a selected colour palette as a bar of colours.
#' @param ... Additional arguments passed on to ggplot functions.
#' @param chromata A vector of colours from one of the `ltc` palettes.
#' @return A ggplot2 object showing the selected colours.
#' @examples
#' \dontrun{
#' paloma <- ltc("paloma")
#' pltc(paloma)
#'}
#' @importFrom ggplot2 ggplot aes geom_tile theme_void labs theme element_text geom_text
#' @importFrom dplyr filter %>%
#' @export
pltc <- function(chromata, ...) {

  # Assuming info is available in the global environment or it's part of your package data.
  info2 = info %>%
    filter(palette_name == attributes(chromata)$name)

  n <- length(chromata)
  df <- data.frame(xvals = c(1:n), yvals = rep(1, n), text = chromata[1:n])

  ggplot(df, aes(x = xvals, y = yvals)) +
    geom_tile(fill = chromata,
              colour = "white",
              size = 1) +
    geom_text(aes(label=text), color="#333333", nudge_y = -0.53) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5, face="italic"),
          plot.subtitle = element_text(hjust = 0.5, size=10),    # Subtitle customization
          legend.position = "none") +
    labs(title = info2$palette_name, subtitle = info2$bio)
}

#' @title Plot a Colour Palette as a Sinus Curve
#' @description Visualizes a selected colour palette as a sinusoidal curve.
#' @param ... Additional arguments passed on to ggplot functions.
#' @param chromata A vector of colours from one of the `ltc` palettes.
#' @return A sinusoidal curve with the selected colors.
#' @examples
#' \dontrun{
#' paloma <- ltc("paloma")
#' plts(paloma)
#'}
#' @export

plts <- function(chromata, ...) {
    x <- outer(
    seq(-pi, pi, length.out = 50),
    seq(0, pi, length.out = length(chromata)),
    function(x, y) sin(x - y))
    graphics::matplot(x, type = "l", lwd = 4, lty = 1, col = chromata, ...)
}

#' @title Plot a Colour Palette as a Bird
#' @description Visualizes a selected colour palette in the form of a bird drawing.
#'
#' @param chrom A vector of colours from one of the `ltc` palettes.
#' @return A ggplot2 object showing a bird drawing using the selected colours.
#' @examples
#' \dontrun{
#' paloma <- ltc("paloma")
#' bird(paloma)
#'}
#' @importFrom ggplot2 ggplot theme_void labs theme
#' @importFrom ggforce geom_shape
#' @importFrom dplyr filter
#' @importFrom dplyr %>%
#' @importFrom ggplot2 element_text
#' @export

bird <- function(chrom){
  data=data.frame(x1=0,x2=5,y1=-5,y2=5, x3=4.5,x4=5.5,y3=0,y4=12)

shape1 <- data.frame(
    x = c(2, 3, 3, 2),
    y = c(0, 2, 8, 10)
  )
shape2 <- data.frame(
    x2=c(2,2.5,2.5,2),
    y2=c(1,3,-2,-4)
  )
shape3 <- data.frame(
    x3=c(3,3.22,3),
    y3=c(8,8,7.33)
  )
shape4 <- data.frame(
    x4=c(1.99,2.5, 3.01,3.01,2,2),
    y4=c(5, 6.5,5,  2, -0.01,1)
  )

info2 = info %>%
  filter(palette_name==attributes(chrom)$name)

  ggplot2::ggplot() +
    ggplot2::geom_rect(data=data, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y4), fill=chrom[1],color="NA") +
    ggforce::geom_shape(data=shape1, aes(x = x, y = y), fill=chrom[2]) +
    ggforce::geom_shape(data=shape3, aes(x=x3,y=y3), fill=chrom[3]) +
    ggforce::geom_shape(data=shape4, aes(x=x4,y=y4), fill=chrom[4]) +
    ggforce::geom_shape(data=shape2, aes(x=x2,y=y2), fill=chrom[5]) +
    ggplot2::theme_void() +
    ggplot2::labs(title = info2$palette_name, subtitle = info2$bio) +
    ggplot2::theme(plot.title = element_text(hjust = 0.5, face="italic"),
                   plot.subtitle = element_text(hjust = 0.5, size=10))
}


