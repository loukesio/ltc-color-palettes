test_that("ltc() resolves quoted, bare, and variable palette names", {
  expected <- palettes[["remains"]]

  # quoted string
  expect_identical(as.character(ltc("remains")), expected)

  # bare / unquoted palette name
  expect_identical(as.character(ltc(remains)), expected)

  # a variable holding a palette name (regression: previously errored with
  # "Palette 'pal' not found" because substitute() captured the symbol `pal`)
  pal <- "remains"
  expect_identical(as.character(ltc(name = pal)), expected)

  # all three call styles agree
  expect_identical(as.character(ltc(name = pal)), as.character(ltc(remains)))
})

test_that("ltc() still errors clearly on an unknown palette name", {
  expect_error(ltc("not_a_palette"), "not found")

  missing_var <- "not_a_palette"
  expect_error(ltc(name = missing_var), "not found")
})
