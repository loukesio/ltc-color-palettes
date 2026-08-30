# ltc

> Artistic and nature-inspired colour palettes for R

📖 **Website & interactive palette explorer:**
<https://loukesio.github.io/ltc-color-palettes/>

**ltc** is a collection of 32 colour palettes inspired by art, nature,
and literature — the paintings and life of Pablo Picasso, Booker Prize
novels, Pantone releases — each with a backstory that gives the colours
context and meaning. Every palette works as a discrete, continuous, or
diverging scale, plugs directly into ggplot2 via
[`scale_fill_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_fill_ltc.md)
/
[`scale_colour_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_colour_ltc.md),
can be darkened, lightened, or desaturated in place, and can be checked
for colour-vision accessibility.

## Installation

![](ReadMEFigures/new_logo_ltc.png)

``` r

# Install the released version from CRAN
install.packages("ltc")

# Or the latest development version from GitHub:
# install.packages("devtools")
devtools::install_github("loukesio/ltc-color-palettes")

# and load it
library(ltc)
```

## The one-glance demo

All 32 palettes at a glance:

![](ReadMEFigures/all_palettes.png)

Every palette, shown across six chart types — a map, a Voronoi treemap,
a heatmap, a bubble chart, a barplot and a streamgraph:

![](ReadMEFigures/palettes_showcase.gif)

Try them yourself in the [**interactive palette
explorer**](https://loukesio.github.io/ltc-color-palettes/palette-explorer.html)
— switch between palettes, darken or brighten them, and check how they
hold up under colour-vision deficiency.

Two examples on real data. A discrete scale — life expectancy against
income across the world in 2007, coloured by continent with the `expevo`
palette:

![](ReadMEFigures/bubble_gapminder.png)

And a continuous scale — estimated GDP per capita across Europe, drawn
with the `heatmap0` palette:

![](ReadMEFigures/europe_map.png)

Every function below follows the same pattern: what it is for, the
arguments that matter (with their defaults), and a worked example.

## The functions

### `ltc()` — select a palette

**What it’s for:** picking a palette by name — with or without quotes,
or from a variable holding the name — and printing it in the console
with the actual colours visible.

| Argument | Default | What it does |
|----|----|----|
| `name` | — | The palette name: `ltc(paloma)`, `ltc("paloma")`, or `pal <- "paloma"; ltc(name = pal)` |
| `n` | all colours | How many colours to take |
| `type` | `"discrete"` | `"discrete"` picks the first `n`; `"continuous"` interpolates a ramp of `n` |

``` r

library(ltc)
names(palettes)
#>  [1] "paloma"     "maya"       "dora"       "ploen"      "olga"      
#>  [6] "mterese"    "gaby"       "franscoise" "fernande"   "sylvie"    
#> [11] "expevo"     "minou"      "kiss"       "hat"        "reading"   
#> [16] "alger"      "trio1"      "trio2"      "trio3"      "trio4"     
#> [21] "heatmap0"   "pantone23"  "remains"    "midnight"   "lincoln"   
#> [26] "luminaries" "seafarer"   "shuggie"    "heatmap1"   "heatmap2"  
#> [31] "heatmap3"   "casa_natal"

alger <- ltc("alger")
plot(alger)
```

![](ReadMEFigures/alger.png)

Each palette’s backstory lives in the bundled `info` data frame —
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) prints it as
the subtitle.

### `bird()` — print a palette as a bird

**What it’s for:** the ltc signature — visualising a palette (of at
least 5 colours) as a bird drawing:

``` r

pantone23 <- ltc("pantone23")
bird(pantone23)
```

![](ReadMEFigures/pantone_bird_ltc.png)

### `scale_fill_ltc()` / `scale_colour_ltc()` — ggplot2 scales

**What they’re for:** using a palette directly in ggplot2, exactly like
`scale_fill_viridis()` — no `scale_fill_manual(values = ...)` needed.
[`scale_color_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_colour_ltc.md)
is the same function under the US spelling.

| Argument    | Default | What it does                                 |
|-------------|---------|----------------------------------------------|
| `name`      | —       | Palette name, quoted or bare                 |
| `discrete`  | `TRUE`  | `FALSE` builds a continuous gradient instead |
| `direction` | `1`     | `-1` reverses the palette                    |

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

# reverse the palette
scale_colour_ltc(alger, direction = -1)
```

For other scale constructors,
[`ltc_pal()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc_pal.md)
returns a palette function of `n`:

``` r

ltc_pal(maya)(3)
#> [1] "#3d5a80" "#98c1d9" "#e0fbfc"
```

### `adjust_ltc()` / `desaturate_ltc()` — tune a palette

**What they’re for:** darkening, lightening, or muting a palette without
leaving the package.

| Argument | Default | What it does |
|----|----|----|
| `palette_name` | — | Palette name, quoted or bare |
| `amount` | `0` / `0.5` | [`adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/adjust_ltc.md): negative darkens, positive lightens; [`desaturate_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/desaturate_ltc.md): 0–1 mutes |
| `which` | all colours | Restrict to specific colour positions, e.g. `c(1, 4)` |

``` r

adjust_ltc(maya, amount = -30)      # darker
adjust_ltc(maya, amount =  30)      # lighter
desaturate_ltc(maya, amount = 0.6)  # muted

# tune individual colours, or give each its own amount
adjust_ltc(maya, amount = -25, which = c(1, 4))
custom_adjust_ltc(maya, c(-40, -20, 0, 20, 40))
```

![](ReadMEFigures/adjust_showcase.png)

### `ltc_cvd()` — check colour-vision accessibility

**What it’s for:** simulating how a palette looks to viewers with the
three main types of colour-vision deficiency, so you can check that the
colours stay distinct.

| Argument   | Default | What it does                        |
|------------|---------|-------------------------------------|
| `name`     | —       | Palette name, quoted or bare        |
| `severity` | `1`     | Simulation strength, 0–1            |
| `labels`   | `TRUE`  | Print the hex codes on the swatches |

``` r

ltc_cvd(maya)                     # normal + deuteranopia / protanopia / tritanopia
ltc_cvd("expevo", severity = 0.6) # milder simulation
```

![](ReadMEFigures/cvd_showcase.png)

## Palettes in action

A hexagon-density plot with a continuous `heatmap0` ramp:

``` r

library(ggplot2)
pal <- ltc("heatmap0", 10, "continuous")

ggplot(data.frame(x = rnorm(1e4), y = rnorm(1e4)), aes(x = x, y = y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_gradientn(colours = pal) +
  theme_void()
```

![](ReadMEFigures/hexagon_plot_ltc.png)

And a filled histogram from a 5-colour `alger` ramp:

``` r

pal <- ltc("alger", 5, "continuous")

ggplot(diamonds, aes(price, fill = cut)) +
  geom_histogram(binwidth = 500, position = "fill") +
  scale_fill_manual(values = pal) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
```

![](ReadMEFigures/histogram_plot_ltc.png)

## API reference

| Function | Purpose |
|----|----|
| [`ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc.md) | Select a palette by name (`n`, `type = "discrete"/"continuous"`) |
| [`plot()`](https://rdrr.io/r/graphics/plot.default.html) | Print a palette as colour tiles, with its backstory |
| [`bird()`](https://loukesio.github.io/ltc-color-palettes/reference/bird.md) | Print a palette as a bird drawing |
| [`scale_fill_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_fill_ltc.md) / [`scale_colour_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_colour_ltc.md) | ggplot2 fill/colour scales (`discrete`, `direction`) |
| [`ltc_pal()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc_pal.md) | Palette function of `n`, for other scale constructors |
| [`adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/adjust_ltc.md) | Darken (negative) or lighten (positive) colours |
| [`custom_adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/custom_adjust_ltc.md) | Per-colour adjustment amounts |
| [`desaturate_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/desaturate_ltc.md) | Mute colours |
| [`ltc_cvd()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc_cvd.md) | Simulate colour-vision deficiency |
| `palettes` / `info` | The palette list and the backstories |

## Contributions

The `ltc` package is developed and maintained by Loukas Theodosiou
(<theodosiou@evolbio.mpg.de>). For the palettes I drew inspiration from
the drawings and life of Pablo Picasso as well as from the following
books:

![](ReadMEFigures/book1.jpeg)![](ReadMEFigures/book2.jpeg)

ltc pairs naturally with its sibling packages
[ggvmap](https://github.com/loukesio/ggvmap) (Voronoi treemaps) and
[ggsynteny](https://github.com/loukesio/ggsynteny) (synteny plots) —
both accept every ltc palette by name.

## Roadmap

Version 0.4.0 is on CRAN. Planned for the next version:

[`ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc.md)
accepts a variable holding a palette name,
e.g. `pal <- "remains"; ltc(name = pal)` — in addition to
`ltc("remains")` and `ltc(remains)`. *(done)*

Apply the same name resolution to
[`adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/adjust_ltc.md),
[`custom_adjust_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/custom_adjust_ltc.md)
and
[`desaturate_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/desaturate_ltc.md)
so they also accept a variable holding a palette name. *(done)*

Add ggplot2 scales —
[`scale_fill_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_fill_ltc.md),
[`scale_colour_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_colour_ltc.md),
[`scale_color_ltc()`](https://loukesio.github.io/ltc-color-palettes/reference/scale_colour_ltc.md)
and
[`ltc_pal()`](https://loukesio.github.io/ltc-color-palettes/reference/ltc_pal.md)
— in the style of `scale_fill_viridis()`. *(done)*

## License

MIT
