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
