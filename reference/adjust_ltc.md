# Adjust Lightness of Palette Colors

Darken or lighten an entire palette or specific colors within it. Uses
the colorspace package for perceptually uniform adjustments.

## Usage

``` r
adjust_ltc(palette_name, amount = 0, which = NULL)
```

## Arguments

- palette_name:

  Character or unquoted name. Name of the ltc palette to adjust.

- amount:

  Numeric. Amount to adjust lightness (-100 to 100). Negative values
  darken, positive values lighten. Default is 0 (no change).

- which:

  Integer vector. Which colors to adjust (e.g., c(1, 3) for 1st and
  3rd). If NULL (default), adjusts all colors.

## Value

A vector of adjusted hex color codes with class "ltc"

## Examples

``` r
# \donttest{
# Darken entire palette
adjust_ltc(alger, amount = -20)
#> alger_adj-20
#>    #000000
#>    #014A4A
#>    #839D94
#>    #C78325
#>    #994139

# Lighten entire palette
adjust_ltc("maya", amount = 30)
#> maya_adj30
#>    #7088AE
#>    #ACD5ED
#>    #E3FEFF
#>    #FF9785
#>    #626977

# Darken only specific colors
adjust_ltc(remains, amount = -25, which = c(2, 4))
#> remains_adj-25
#>    #69326E
#>    #AFAD6D
#>    #FF6D1F
#>    #B09A03
# }
```
