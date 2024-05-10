[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/icon)](https://cran.r-project.org/package=icons)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![GitHub clones](https://img.shields.io/badge/Clones-1000+-blue)]()


## Install package
Install the package using the following commands  <img align="right" src="ReadMEFigures/new_logo_ltc.png" width=400>

```r
# for now, you can install the developmental version of ltc
# first you need to install the devtools package 
# in case you have not already installed
install.packages("devtools") 
# and load it
library(devtools)

# Then you can install the dev version of the ltc
install_github("loukesio/ltc_palettes")
# and load it
library(ltc)
```

<img src="ReadMEFigures/all_colors_ltc.png" width=1000>

## How can I use the `ltc` package?

### Show all palettes
``` r
names(palettes)
#>  [1] "paloma"     "maya"       "dora"       "ploen"      "olga"      
#>  [6] "mterese"    "gaby"       "franscoise" "fernande"   "sylvie"    
#> [11] "crbhits"    "expevo"     "minou"      "kiss"       "hat"       
#> [16] "reading"    "ten_colors" "alger"      "trio1"      "trio2"     
#> [21] "trio3"      "trio4"      "heatmap"    "pantone23"
```
<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>

### Choose the palette you like and print it
- choose it using the `ltc` command.
``` r
alger <- ltc("alger") #in this case you select alger
```
- after choosing the palette print it using the `pltc` command!
``` r
pltc(alger)
```
<img src="ReadMEFigures/alger.png" width=450>

- you can also print the palette you have chosen in a bird-shape, in here we are using `dora`

``` r
library(ltc)
pantone23 <- ltc("pantone23")
bird(pantone23)
```
<img src="ReadMEFigures/pantone_bird_ltc.png" width=450>

<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>

### Test how the palette looks like in plots...

- Example 1 - Hexagon diagram

``` r
library(ggplot2)
library(ltc)
pal=ltc("heatmap",10,"continuous")

ggplot(data.frame(x = rnorm(1e4), y = rnorm(1e4)), aes(x = x, y = y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_gradientn(colours = pal) +
  theme_void()
```
<img src="ReadMEFigures/hexagon_plot_ltc.png" width=450>

<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>


- Example 2 - Histogram

``` r
library(ltc)
library(ggplot2)
pal=ltc("alger",5,"continuous")

ggplot(diamonds, aes(price, fill = cut)) +
  geom_histogram(binwidth = 500, position = "fill") +
  scale_fill_manual(values = pal) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
```
<img src="ReadMEFigures/histogram_plot_ltc.png" width=450>

<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>

- Example 3 - Line plot
``` r
library(ltc)
pal=ltc("maya",7,"continuous")
plts(pal, main = "maya")
```
<img src="ReadMEFigures/line_plot_ltc.png" width=450>

<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>

- Example 4 - Transparency blend

``` r
library(ltc)
pal=ltc("mterese",500,"continuous")
plts(col2transparent(pal, 75))
plts(pal, main = "mterese")
```

<img src="ReadMEFigures/transparency_blend_ltc.png" width=450>

<sup>Created on 2023-09-03 with [reprex v2.0.2](https://reprex.tidyverse.org)</sup>


## Contributions
Loukas Theodosiou (theoodosiou@evolbio.mpg.de) and Kristian Ullrich (ullrich@evolbio.mpg.de) have contributed to the development of this package. We have drawn inspiration from the drawings and life of Pablo Picasso as well as from the following books 
<p float="left">
  <img src="ReadMEFigures/book1.jpeg" width="100" />
  <img src="ReadMEFigures/book2.jpeg" width="100" />
</p> 
