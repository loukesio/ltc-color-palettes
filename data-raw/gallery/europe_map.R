# Gallery: Europe choropleth coloured with a continuous ltc palette.
# GDP per capita by country, Lambert Azimuthal Equal-Area (EPSG:3035).
# Data: Natural Earth (bundled, no API key needed).

source(file.path("data-raw", "gallery", "_gallery_theme.R"))
suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(rnaturalearth)
})

world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(continent == "Europe" | name %in% c("Turkey", "Cyprus")) %>%
  mutate(gdp_pc = ifelse(pop_est > 0, gdp_md * 1e6 / pop_est, NA_real_)) %>%
  filter(name != "Russia")   # Russia's extent would swamp the frame

# Lambert Azimuthal Equal-Area for Europe, then crop to a tidy window.
eu <- st_transform(world, 3035)
bb <- st_bbox(c(xmin = 2.5e6, xmax = 6.0e6, ymin = 1.4e6, ymax = 5.4e6),
              crs = st_crs(3035))
eu <- st_crop(eu, bb)

pal <- ltc_pal("heatmap0", type = "continuous")   # deep teal -> warm ochre -> red

p <- ggplot(eu) +
  geom_sf(aes(fill = gdp_pc), colour = "white", linewidth = 0.25) +
  scale_fill_gradientn(
    colours = pal, na.value = "#EDEDED",
    limits = c(0, 90000), oob = scales::squish,
    breaks = c(0, 30000, 60000, 90000),
    labels = c("$0k", "$30k", "$60k", "$90k+"),
    name   = "GDP per capita",
    guide  = guide_colourbar(barwidth = 0.8, barheight = 9,
                             ticks.colour = "white", frame.colour = NA)
  ) +
  coord_sf(expand = FALSE) +
  labs(
    title    = "A continent, priced",
    subtitle = "Estimated GDP per capita across Europe, drawn with the ltc \"heatmap0\" palette",
    caption  = "Source: Natural Earth  ·  Projection: LAEA Europe (EPSG:3035)  ·  ltc R package"
  ) +
  theme_ltc() +
  theme(
    axis.title = element_blank(),
    axis.text  = element_blank(),
    panel.grid = element_line(colour = "#F1F1F1", linewidth = 0.3)
  )

gallery_save(p, "europe_map.png", width = 8.2, height = 8.4)
