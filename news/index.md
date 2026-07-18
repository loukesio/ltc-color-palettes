# Changelog

## ltc 0.3.0

CRAN release: 2026-01-16

### CRAN Release Preparation

- Updated package for CRAN submission
- Improved documentation and examples
- Enhanced package metadata
- All R CMD check tests pass successfully

### New Features

- Added `colorspace` package dependency for color manipulation
- New function:
  [`adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/adjust_ltc.md) -
  Darken or lighten palette colors
- New function:
  [`custom_adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/custom_adjust_ltc.md) -
  Apply custom adjustments to individual colors
- New function:
  [`desaturate_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/desaturate_ltc.md) -
  Desaturate palette colors
- All color adjustments use perceptually uniform methods from colorspace

## ltc 0.2.0

- Package improvements and bug fixes
- Enhanced color palette functions

## ltc 0.1.0

- Initial development version
- Added a `NEWS.md` file to track changes to the package
- Core functionality for artistic and nature-inspired color palettes
