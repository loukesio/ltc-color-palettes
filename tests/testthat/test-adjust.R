# The adjustment helpers should resolve palette names the same three ways as
# ltc(): quoted, bare, and a variable holding the name.

test_that("adjust_ltc() accepts quoted, bare, and variable palette names", {
  pal <- "remains"
  ref <- as.character(adjust_ltc("remains", amount = -20))

  expect_identical(as.character(adjust_ltc(remains, amount = -20)), ref)  # bare
  expect_identical(as.character(adjust_ltc(pal, amount = -20)), ref)      # variable
})

test_that("desaturate_ltc() accepts a variable holding a palette name", {
  pal <- "remains"
  ref <- as.character(desaturate_ltc("remains", amount = 0.5))

  expect_identical(as.character(desaturate_ltc(pal, amount = 0.5)), ref)
})

test_that("custom_adjust_ltc() accepts a variable holding a palette name", {
  pal <- "remains"
  adj <- c(-30, 0, 40, 0)  # remains has four colours
  ref <- as.character(custom_adjust_ltc("remains", adj))

  expect_identical(as.character(custom_adjust_ltc(pal, adj)), ref)
})

test_that("adjustment helpers still error on an unknown palette name", {
  missing_var <- "not_a_palette"
  expect_error(adjust_ltc(missing_var, amount = -20), "not found")
  expect_error(desaturate_ltc(missing_var, amount = 0.5), "not found")
})
