# ggplot2 Fill Scale from an ltc Palette

Colours the `fill` aesthetic with an ltc palette, the way
`scale_fill_viridis()` does. Set `discrete = FALSE` for a continuous
scale.

## Usage

``` r
scale_fill_ltc(name, discrete = TRUE, direction = 1, ...)
```

## Arguments

- name:

  Character or unquoted name. The name of the desired palette.

- discrete:

  `TRUE` for a discrete scale, `FALSE` for a continuous one.

- direction:

  1 keeps the palette order, -1 reverses it.

- ...:

  Passed on to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)
  when `discrete = TRUE`, or to
  [`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  when `discrete = FALSE`.

## Value

A ggplot2 scale, to add to a plot.

## Examples

``` r
library(ggplot2)

# discrete
ggplot(mtcars, aes(factor(cyl), mpg, fill = factor(cyl))) +
  geom_boxplot() +
  scale_fill_ltc(maya)


# continuous
ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
  geom_raster() +
  scale_fill_ltc(heatmap0, discrete = FALSE)
```
