# List of colour palettes

A list containing predefined colour palettes with artistic backstories.

This function provides the desired colour palette by name. You can call
it with or without quotes: ltc(paloma) or ltc("paloma")

## Usage

``` r
palettes

ltc(name, n, type = c("discrete", "continuous"))
```

## Format

An object of class `list` of length 31.

## Arguments

- name:

  Character or unquoted name. The name of the desired palette.

- n:

  Integer. The number of colors you want from the palette. If omitted,
  it uses all colors from the palette.

- type:

  The type of palette. Either "discrete" or "continuous".

## Value

A vector of hex color codes with class "ltc"

## Details

ltc: A Collection of Art-inspired Colour Palettes

This package provides a collection of color palettes inspired by art,
nature, and personal preferences. Each palette has a backstory,
providing context and meaning to the colors.

## Examples

``` r
# Load a palette (with or without quotes)
ltc(paloma)
#> paloma
#>    #83AF9B
#>    #C8C8A9
#>    #f8da8a
#>    #f7bf95
#>    #fe8ca1
ltc("maya")
#> maya
#>    #3d5a80
#>    #98c1d9
#>    #e0fbfc
#>    #ee6c4d
#>    #293241

# Select first 3 colors
ltc(maya, n = 3)
#> maya
#>    #3d5a80
#>    #98c1d9
#>    #e0fbfc

# Generate continuous palette
ltc(remains, n = 10, type = "continuous")
#> remains
#>    #69326E
#>    #957089
#>    #C1AEA4
#>    #EEEDC0
#>    #F3C28A
#>    #F99754
#>    #FF6D1F
#>    #F98F30
#>    #F3B142
#>    #EED455
```
