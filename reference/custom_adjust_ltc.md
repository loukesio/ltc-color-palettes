# Create Custom Palette with Individual Color Adjustments

Apply different lightness adjustments to each color in a palette.

## Usage

``` r
custom_adjust_ltc(palette_name, adjustments)
```

## Arguments

- palette_name:

  Character or unquoted name. Name of the ltc palette.

- adjustments:

  Numeric vector. Lightness adjustments for each color (-100 to 100).
  Length must match the palette length.

## Value

A vector of adjusted hex color codes with class "ltc"

## Examples

``` r
# \donttest{
# Different adjustment for each color
custom_adjust_ltc(remains, c(-30, 0, 40, 0))
#> remains_custom
#>    #521C57
#>    #EEEDC0
#>    #FFAD9A
#>    #EED455

# Create gradient effect
custom_adjust_ltc("maya", c(-40, -20, 0, 20, 40))
#> maya_custom
#>    #223752
#>    #7198AE
#>    #e0fbfc
#>    #FF856D
#>    #767D8B
# }
```
