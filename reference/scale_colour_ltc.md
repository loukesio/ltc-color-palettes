# ggplot2 Colour Scale from an ltc Palette

Colours the `colour` aesthetic with an ltc palette, the way
`scale_colour_viridis()` does. Set `discrete = FALSE` for a continuous
scale. `scale_color_ltc()` is the same function under the US spelling.

## Usage

``` r
scale_colour_ltc(name, discrete = TRUE, direction = 1, ...)

scale_color_ltc(name, discrete = TRUE, direction = 1, ...)
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
  [`ggplot2::scale_colour_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  when `discrete = FALSE`.

## Value

A ggplot2 scale, to add to a plot.

## Examples

``` r
library(ggplot2)

ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
  geom_point(size = 3) +
  scale_colour_ltc(alger)
```
