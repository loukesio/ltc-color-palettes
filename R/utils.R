# Resolve a palette name from a captured argument expression.
# Supports three call styles used across the package:
#   f("remains")               a quoted string
#   f(remains)                 a bare palette-name symbol
#   pal <- "remains"; f(pal)   a variable holding a name string
# `name_expr` is the result of substitute() on the name argument; `env` is the
# environment in which to look up a variable (usually the caller's frame).
# Internal helper (not exported).
resolve_palette_name <- function(name_expr, env) {
  if (is.character(name_expr)) {
    return(name_expr)
  }
  # a bare symbol that is itself a palette name -> use it, never evaluate
  if (is.name(name_expr) && !is.null(palettes[[as.character(name_expr)]])) {
    return(as.character(name_expr))
  }
  # otherwise a variable or expression: use its value if it is a single string,
  # else fall back to the symbol so the "not found" error still fires clearly
  val <- tryCatch(eval(name_expr, env), error = function(e) NULL)
  if (is.character(val) && length(val) == 1L) val else as.character(name_expr)
}
