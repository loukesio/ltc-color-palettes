# Plot a Colour Palette as a Bird

Visualizes a selected colour palette in the form of a bird drawing.
Requires at least 5 colors in the palette.

## Usage

``` r
bird(chrom)
```

## Arguments

- chrom:

  An ltc palette object

## Value

A ggplot2 object showing a bird drawing using the selected colours.

## Examples

``` r
# \donttest{
# Create a bird visualization
pal <- ltc(paloma)
bird(pal)

# }
```
