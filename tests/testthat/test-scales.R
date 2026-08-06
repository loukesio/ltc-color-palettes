test_that("ltc_pal() resolves quoted, bare, and variable palette names", {
  expected <- palettes[["maya"]][1:3]

  expect_identical(ltc_pal("maya")(3), expected)
  expect_identical(ltc_pal(maya)(3), expected)

  pal <- "maya"
  expect_identical(ltc_pal(pal)(3), expected)
})

test_that("ltc_pal() reverses the palette when direction is -1", {
  expect_identical(ltc_pal(maya, direction = -1)(5), rev(palettes[["maya"]]))
  expect_error(ltc_pal(maya, direction = 0), "must be 1 or -1")
})

test_that("ltc_pal() interpolates rather than failing past the palette length", {
  n <- length(palettes[["maya"]])
  out <- ltc_pal(maya)(n + 3)

  expect_length(out, n + 3)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", out)))
})

test_that("ltc_pal() errors clearly on an unknown palette name", {
  expect_error(ltc_pal("not_a_palette"), "not found")
})

test_that("scale_fill_ltc() colours a discrete scale from the palette", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg, fill = factor(cyl))) +
    ggplot2::geom_boxplot() +
    scale_fill_ltc(maya)

  fills <- unique(ggplot2::ggplot_build(p)$data[[1]]$fill)
  expect_setequal(tolower(fills), tolower(palettes[["maya"]][1:3]))
})

test_that("scale_fill_ltc(discrete = FALSE) builds a continuous scale", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, fill = density)) +
    ggplot2::geom_raster() +
    scale_fill_ltc(heatmap0, discrete = FALSE)

  fills <- ggplot2::ggplot_build(p)$data[[1]]$fill
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", fills)))
  # a continuous ramp uses far more than the nine colours it was built from
  expect_gt(length(unique(fills)), length(palettes[["heatmap0"]]))
})

test_that("the colour scales accept both spellings and a variable name", {
  skip_if_not_installed("ggplot2")

  build <- function(sc) {
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg, colour = factor(cyl))) +
      ggplot2::geom_point() + sc
    sort(unique(ggplot2::ggplot_build(p)$data[[1]]$colour))
  }

  pal <- "alger"
  expect_identical(build(scale_colour_ltc(alger)), build(scale_color_ltc(alger)))
  expect_identical(build(scale_colour_ltc(pal)), build(scale_colour_ltc("alger")))
})
