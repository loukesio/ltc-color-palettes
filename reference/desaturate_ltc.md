# Desaturate Palette Colors

Reduce color saturation (make colors more gray).

## Usage

``` r
desaturate_ltc(palette_name, amount = 0.5, which = NULL)
```

## Arguments

- palette_name:

  Character or unquoted name. Name of the ltc palette.

- amount:

  Numeric. Desaturation amount (0 to 1). 0 = no change, 1 = completely
  gray.

- which:

  Integer vector. Which colors to desaturate. If NULL (default), affects
  all colors.

## Value

A vector of desaturated hex color codes with class "ltc"

## Examples

``` r
# \donttest{
# Desaturate entire palette
desaturate_ltc(luminaries, amount = 0.5)
#> luminaries_desat
#>    #D57967
#>    #344C4F
#>    #292F33
#>    #FAF6ED
#>    #E7D5AF
#>    #D6DADB

# Desaturate only specific colors
desaturate_ltc("heatmap2", amount = 0.7, which = c(1, 2))
#> heatmap2_desat
#>    #8F5355
#>    #CDB2A9
#>    #f7f7f7
#>    #92c5de
#>    #0571b0
# }
```
