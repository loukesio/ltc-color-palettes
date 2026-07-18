# Plot a Colour Palette

Visualizes a selected colour palette as a bar of colours.

## Usage

``` r
# S3 method for class 'ltc'
plot(x, ...)
```

## Arguments

- x:

  An ltc palette object

- ...:

  Additional arguments (currently unused).

## Value

A ggplot2 object showing the selected colours.

## Examples

``` r
# \donttest{
# Create and plot a palette
pal <- ltc(paloma)
plot(pal)

# }
```
