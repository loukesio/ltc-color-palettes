# Build a Palette Function from an ltc Palette

Returns a function of `n` that gives `n` colours from the named palette,
which is the form ggplot2 scales expect. Like the rest of the package,
the name may be quoted, bare, or held in a variable.

If more colours are asked for than the palette holds, the palette is
interpolated to that length rather than failing, so a scale never breaks
on a data set with more groups than expected.

## Usage

``` r
ltc_pal(name, direction = 1)
```

## Arguments

- name:

  Character or unquoted name. The name of the desired palette.

- direction:

  1 keeps the palette order, -1 reverses it.

## Value

A function taking `n` and returning a character vector of `n` hex colour
codes.

## Examples

``` r
pal <- ltc_pal(maya)
pal(3)
#> [1] "#3d5a80" "#98c1d9" "#e0fbfc"

ltc_pal("expevo", direction = -1)(5)
#> [1] "#808080" "#1d457f" "#8B4769" "#00AFBB" "#E7B800"
```
