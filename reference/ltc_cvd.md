# Preview a Palette under Colour Vision Deficiency (CVD)

Simulates how an `ltc` palette appears to viewers with the three main
types of colour vision deficiency (colour blindness) and shows the
result as rows of swatches. Useful for checking whether a palette stays
distinguishable for colour-blind readers.

The simulation uses colorspace: deuteranopia (green-weak, the most
common), protanopia (red-weak) and tritanopia (blue-weak).

## Usage

``` r
ltc_cvd(name, severity = 1, labels = TRUE)
```

## Arguments

- name:

  Character or unquoted palette name (e.g. `dora` or `"dora"`), or a
  character vector of hex colours.

- severity:

  Numeric in `[0, 1]`. Strength of the deficiency, where `1` is the full
  dichromatic simulation (the default) and lower values give milder
  anomalous-trichromacy simulations.

- labels:

  Logical. If `TRUE` (default) the hex codes are printed on the
  swatches.

## Value

A ggplot2 object: one row of swatches per vision type (Normal,
Deuteranopia, Protanopia, Tritanopia).

## Examples

``` r
# \donttest{
ltc_cvd(dora)

ltc_cvd("expevo", severity = 0.6)

# }
```
