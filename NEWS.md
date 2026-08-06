# ltc 0.4.0.9000 (development version)

* New ggplot2 scales, in the style of `scale_fill_viridis()`:
  `scale_fill_ltc()`, `scale_colour_ltc()` and `scale_color_ltc()`. Each takes
  a palette name, `discrete = TRUE` (the default) or `FALSE` for a continuous
  scale, and `direction = -1` to reverse the palette. Plots no longer need
  `scale_fill_manual(values = ltc(...))`.
* New `ltc_pal()` returns a palette function of `n`, for use with other scale
  constructors. It interpolates when asked for more colours than the palette
  holds, so a scale does not break on more groups than expected.
* The all-palettes README figure is now a gallery of treemap palette cards,
  showing each colour's role, share and codes.

* `ltc()`, `adjust_ltc()`, `custom_adjust_ltc()` and `desaturate_ltc()` now
  accept a palette name supplied as a variable (e.g.
  `pal <- "remains"; ltc(pal)`), in addition to a quoted string and a bare name.
  The name-resolution logic is shared and covered by testthat tests.

# ltc 0.4.0

## New features

* New palette `casa_natal`, inspired by Casa Natal on the Plaza de la Merced,
  the birthplace of Picasso.
* New function `ltc_cvd()` previews a palette under the three main types of
  colour-vision deficiency (deuteranopia, protanopia, tritanopia).

## Website and documentation

* Added a **pkgdown** website with an interactive palette explorer (every
  palette across six chart types, with brightness and colour-vision controls).
* Redesigned the all-palettes overview figure and added a gallery of example
  charts plus an animated palette showcase.
* README now documents CRAN installation, the palette-adjustment functions,
  and the colour-vision check.

## Other

* Kristian Ullrich removed from the author list.

# ltc 0.3.0

## CRAN Release Preparation

* Updated package for CRAN submission
* Improved documentation and examples
* Enhanced package metadata
* All R CMD check tests pass successfully

## New Features

* Added `colorspace` package dependency for color manipulation
* New function: `adjust_ltc()` - Darken or lighten palette colors
* New function: `custom_adjust_ltc()` - Apply custom adjustments to individual colors
* New function: `desaturate_ltc()` - Desaturate palette colors
* All color adjustments use perceptually uniform methods from colorspace

# ltc 0.2.0

* Package improvements and bug fixes
* Enhanced color palette functions

# ltc 0.1.0

* Initial development version
* Added a `NEWS.md` file to track changes to the package
* Core functionality for artistic and nature-inspired color palettes
