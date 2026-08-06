# Generate the all-palettes overview figure for the README, as a gallery of
# treemap "palette cards".
#
# Everything is derived from the package source, so adding a palette to
# R/ltc_functions.R makes it appear here with no other edit: the section it
# lands in follows from how many colours it has.
#
# Output: ReadMEFigures/all_palettes.png
# Fonts:  IBM Plex Sans / IBM Plex Mono (local installs, Google Fonts fallback)
#
# Two variants, switched with the SHOW_NAMES flag below:
#   FALSE - codes only (hex / RGB / HSL)
#   TRUE  - plus a derived colour name per swatch (nearest CSS colour in Lab)

SHOW_NAMES <- isTRUE(as.logical(Sys.getenv("LTC_CARD_NAMES", "FALSE")))
OUT <- Sys.getenv("LTC_CARD_OUT", "ReadMEFigures/all_palettes.png")

# GitHub renders README images at the content column, about 830px, whatever the
# width attribute says. So the narrower this figure is drawn, the LARGER it
# appears to a reader. W is the main legibility knob, not a canvas size.
W <- as.numeric(Sys.getenv("LTC_CARD_W", "1100"))

# One card per row reads far better than two, at the cost of a longer page.
ONE_UP <- isTRUE(as.logical(Sys.getenv("LTC_CARD_ONEUP", "FALSE")))

# How many code lines a gallery card may show (hex, RGB, HSL). The hero key
# always shows all three; repeating HSL for 290 colours is mostly noise, and
# it is the space that makes tiles cramped.
MAX_CODES <- as.integer(Sys.getenv("LTC_CARD_CODES", "2"))

pkg <- new.env()
sys.source(file.path("R", "ltc_functions.R"), envir = pkg)
palettes <- pkg$palettes
descriptions <- stats::setNames(pkg$info$bio, pkg$info$palette_name)

# --- fonts -----------------------------------------------------------------
add_family <- function(family, regular, bold, google) {
  local_font <- function(f) {
    hit <- c(file.path(path.expand("~/Library/Fonts"), f), file.path("/Library/Fonts", f))
    hit[file.exists(hit)][1]
  }
  reg <- local_font(regular)
  bld <- local_font(bold)
  if (!is.na(reg) && !is.na(bld)) {
    sysfonts::font_add(family, regular = reg, bold = bld)
  } else {
    sysfonts::font_add_google(google, family)
  }
}
add_family("plexsans", "IBMPlexSans-Regular.otf", "IBMPlexSans-Bold.otf", "IBM Plex Sans")
add_family("plexmono", "IBMPlexMono-Regular.otf", "IBMPlexMono-SemiBold.otf", "IBM Plex Mono")
showtext::showtext_auto()

RES <- 150
showtext::showtext_opts(dpi = RES)

# --- palette maths ---------------------------------------------------------

# Share of the plot each colour is meant to carry. Zipf decay: the first colour
# takes ~35%, the top three ~64%, which is the 60-30-10 rule generalised to a
# palette of any length.
zipf_shares <- function(n) {
  w <- 1 / seq_len(n)
  w / sum(w)
}

# Role names follow rank, except that a pale near-grey is called out as the
# neutral regardless of where it sits.
roles_for <- function(hex, n) {
  lab <- t(grDevices::convertColor(t(grDevices::col2rgb(hex) / 255),
                                   from = "sRGB", to = "Lab"))
  L <- lab[1, ]
  chroma <- sqrt(lab[2, ]^2 + lab[3, ]^2)
  r <- ifelse(seq_len(n) == 1, "DOMINANT",
       ifelse(seq_len(n) == 2, "SECONDARY",
       ifelse(seq_len(n) <= 4, "SUPPORT", "ACCENT")))
  r[seq_len(n) > 2 & chroma < 12 & L > 80] <- "NEUTRAL"
  r
}

luminance <- function(hex) {
  rgb <- grDevices::col2rgb(hex) / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  0.2126 * lin[1, ] + 0.7152 * lin[2, ] + 0.0722 * lin[3, ]
}

ink_on <- function(hex) ifelse(luminance(hex) > 0.42, "#1D1D1B", "#FFFFFF")

rgb_label <- function(hex) {
  v <- grDevices::col2rgb(hex)
  paste0("RGB ", paste(v[, 1], collapse = "·"))
}

hsl_label <- function(hex) {
  v <- grDevices::col2rgb(hex)[, 1] / 255
  mx <- max(v); mn <- min(v); d <- mx - mn
  l <- (mx + mn) / 2
  s <- if (d == 0) 0 else d / (1 - abs(2 * l - 1))
  h <- if (d == 0) 0 else if (mx == v[1]) 60 * (((v[2] - v[3]) / d) %% 6)
       else if (mx == v[2]) 60 * ((v[3] - v[1]) / d + 2)
       else 60 * ((v[1] - v[2]) / d + 4)
  paste0("HSL ", paste(round(c(h, s * 100, l * 100)), collapse = "·"))
}

# Nearest CSS colour name, in Lab, so every palette gets names from one rule.
css_names <- local({
  nm <- grDevices::colors(distinct = TRUE)
  nm <- nm[!grepl("[0-9]$", nm)]      # drop the numbered ramps (grey1..grey100)
  lab <- grDevices::convertColor(t(grDevices::col2rgb(nm) / 255),
                                 from = "sRGB", to = "Lab")
  list(name = nm, lab = lab)
})

name_for <- function(hex) {
  target <- grDevices::convertColor(t(grDevices::col2rgb(hex) / 255),
                                    from = "sRGB", to = "Lab")
  d <- sqrt(rowSums((css_names$lab - matrix(target, nrow(css_names$lab), 3,
                                            byrow = TRUE))^2))
  n <- css_names$name[which.min(d)]
  n <- gsub("([a-z])([A-Z])", "\\1 \\2", n)
  n <- gsub("(dark|light|medium|pale|deep)", "\\1 ", n)
  toupper(trimws(gsub("\\s+", " ", n)))
}

# --- squarified treemap ----------------------------------------------------
# Bruls, Huizing & van Wijk (2000). Returns one row per value with x/y/w/h.

squarify <- function(values, x, y, w, h) {
  out <- data.frame(i = integer(), x = numeric(), y = numeric(),
                    w = numeric(), h = numeric())
  idx <- seq_along(values)
  areas <- values / sum(values) * (w * h)

  worst <- function(row, side) {
    s <- sum(row)
    mx <- max(row); mn <- min(row)
    max(side^2 * mx / s^2, s^2 / (side^2 * mn))
  }

  place_row <- function(row, ids, x, y, w, h, vertical) {
    s <- sum(row)
    res <- data.frame(i = ids, x = NA_real_, y = NA_real_, w = NA_real_, h = NA_real_)
    if (vertical) {                     # stack downward in a column of width cw
      cw <- s / h
      cy <- y
      for (k in seq_along(row)) {
        ch <- row[k] / cw
        res[k, 2:5] <- c(x, cy, cw, ch)
        cy <- cy + ch
      }
      list(rects = res, x = x + cw, y = y, w = w - cw, h = h)
    } else {                            # lay out rightward in a row of height rh
      rh <- s / w
      cx <- x
      for (k in seq_along(row)) {
        cwk <- row[k] / rh
        res[k, 2:5] <- c(cx, y, cwk, rh)
        cx <- cx + cwk
      }
      list(rects = res, x = x, y = y + rh, w = w, h = h - rh)
    }
  }

  row <- numeric(0); row_ids <- integer(0); k <- 1
  while (k <= length(areas)) {
    side <- min(w, h)
    cand <- c(row, areas[k])
    if (length(row) == 0 || worst(cand, side) <= worst(row, side)) {
      row <- cand; row_ids <- c(row_ids, idx[k]); k <- k + 1
    } else {
      p <- place_row(row, row_ids, x, y, w, h, vertical = (w >= h))
      out <- rbind(out, p$rects)
      x <- p$x; y <- p$y; w <- p$w; h <- p$h
      row <- numeric(0); row_ids <- integer(0)
    }
  }
  if (length(row)) {
    p <- place_row(row, row_ids, x, y, w, h, vertical = (w >= h))
    out <- rbind(out, p$rects)
  }
  out[order(out$i), ]
}

# --- text helpers ----------------------------------------------------------
# Base R has no letter-spacing, and the tracked uppercase mono labels are the
# signature of this design, so draw them a glyph at a time.

track_width <- function(txt, cex, track, font = 1) {
  ch <- strsplit(txt, "")[[1]]
  sum(graphics::strwidth(ch, cex = cex, font = font, family = "plexmono")) +
    track * max(0, length(ch) - 1)
}

tracked <- function(txt, x, y, cex, col, track, font = 1, adj = 0) {
  ch <- strsplit(txt, "")[[1]]
  if (adj != 0) x <- x - adj * track_width(txt, cex, track, font)
  for (g in ch) {
    graphics::text(x, y, g, cex = cex, col = col, font = font,
                   family = "plexmono", adj = c(0, 0.5), xpd = NA)
    x <- x + graphics::strwidth(g, cex = cex, font = font, family = "plexmono") + track
  }
}

# Same, rotated to read bottom-to-top, for tiles too narrow to take a hex flat.
tracked_v <- function(txt, x, y, cex, col, track, font = 1) {
  for (g in strsplit(txt, "")[[1]]) {
    graphics::text(x, y, g, cex = cex, col = col, font = font, srt = 90,
                   family = "plexmono", adj = c(0, 0.5), xpd = NA)
    y <- y - graphics::strwidth(g, cex = cex, font = font, family = "plexmono") - track
  }
}

sans <- function(txt, x, y, cex, col, font = 1, adj = 0) {
  graphics::text(x, y, txt, cex = cex, col = col, font = font,
                 family = "plexsans", adj = c(adj, 0.5), xpd = NA)
}

# Wrap on width, in user units, for the explainer rail.
wrap_sans <- function(txt, width, cex, font = 1) {
  words <- strsplit(txt, " ")[[1]]
  lines <- character(0); cur <- ""
  for (wd in words) {
    test <- if (nzchar(cur)) paste(cur, wd) else wd
    if (graphics::strwidth(test, cex = cex, font = font, family = "plexsans") > width &&
        nzchar(cur)) {
      lines <- c(lines, cur); cur <- wd
    } else cur <- test
  }
  c(lines, cur)
}

# --- theme -----------------------------------------------------------------
BG        <- "#FAF9F5"
CARD      <- "#FFFFFF"
INK       <- "#1D1D1B"
MUTED     <- "#8A8780"
RULE      <- "#E4E1D9"
TRACK     <- 0.9        # letter-spacing for mono labels, in user units

CEX_SECTION <- 1.55
CEX_NAME    <- 1.45
CEX_BIO     <- 0.72
CEX_LABEL   <- 0.52     # tracked mono: role, "N COLOURS", rail headings
CEX_PCT     <- 1.30
CEX_CODE    <- 0.56
CEX_BODY    <- 0.66

# --- one card --------------------------------------------------------------

card_height <- function(n, wide, max_codes = MAX_CODES) {
  body <- if (n >= 8) 330 else if (n >= 6) 300 else if (n == 5) 265 else 235
  if (!wide) body <- body * 0.86
  # Fewer code lines need less room inside each tile, so the card can be shorter.
  body <- body * c(0.78, 0.89, 1)[max(1, min(3, max_codes))]
  round(66 + body + 26)
}

draw_card <- function(name, x, y, w, wide = TRUE, max_codes = MAX_CODES) {
  cols   <- palettes[[name]]
  n      <- length(cols)
  shares <- zipf_shares(n)
  pct    <- round(shares * 100)
  roles  <- roles_for(cols, n)
  bio    <- descriptions[[name]]
  h      <- card_height(n, wide)

  graphics::rect(x, y, x + w, y + h, col = CARD, border = NA, xpd = NA)

  pad  <- if (wide) 34 else 26
  ix   <- x + pad
  iw   <- w - 2 * pad
  head_y <- y + 34

  sans(name, ix, head_y, CEX_NAME * (if (wide) 1 else 0.82), INK, font = 2)
  nw <- graphics::strwidth(name, cex = CEX_NAME * (if (wide) 1 else 0.82),
                           font = 2, family = "plexsans")
  if (wide) {
    sans(bio, ix + nw + 16, head_y + 3, CEX_BIO, MUTED)
  }
  tracked(paste(n, "COLOURS"), x + w - pad, head_y, CEX_LABEL, MUTED, TRACK, adj = 1)
  if (!wide) {
    sans(bio, ix, head_y + 20, CEX_BIO * 0.94, MUTED)
  }

  rule_y <- y + (if (wide) 58 else 76)
  graphics::segments(ix, rule_y, x + w - pad, rule_y, col = INK, lwd = 1.1, xpd = NA)

  top    <- rule_y + 16
  body_h <- y + h - 26 - top
  tm <- squarify(shares, ix, top, iw, body_h)

  for (k in seq_len(n)) {
    r  <- tm[k, ]
    fg <- ink_on(cols[k])
    graphics::rect(r$x, r$y, r$x + r$w, r$y + r$h, col = cols[k], border = NA, xpd = NA)

    # Progressive disclosure: a tile carries only what fits inside it. Every
    # string is measured against the tile, so nothing ever collides or spills.
    tpad   <- if (r$w < 90) 6 else 11
    room_w <- r$w - 2 * tpad
    room_h <- r$h - 2 * tpad
    if (room_w <= 0 || room_h <= 0) next

    # Last resort for a sliver of a tile: set the hex on its side so that no
    # colour in the figure is ever left without its code.
    hex_w <- track_width(toupper(cols[k]), CEX_CODE, TRACK * 0.5, 2)
    if (hex_w > room_w) {
      if (hex_w <= room_h && r$w > 16) {
        tracked_v(toupper(cols[k]), r$x + r$w / 2, r$y + r$h - tpad,
                  CEX_CODE, fg, TRACK * 0.5, font = 2)
      }
      next
    }

    pct_cex <- CEX_PCT * (if (r$h > 120 && r$w > 150) 1 else 0.74)
    pct_txt <- paste0(pct[k], "%")
    pct_w   <- graphics::strwidth(pct_txt, cex = pct_cex, font = 2, family = "plexsans")
    role_w  <- track_width(roles[k], CEX_LABEL, TRACK)

    show_pct  <- room_h > 26 && pct_w <= room_w
    show_role <- room_h > 26 &&
      role_w + (if (show_pct) pct_w + 14 else 0) <= room_w

    if (show_role) tracked(roles[k], r$x + tpad, r$y + tpad + 6, CEX_LABEL, fg, TRACK)
    if (show_pct)  sans(pct_txt, r$x + r$w - tpad, r$y + tpad + 8, pct_cex, fg,
                        font = 2, adj = 1)

    head_h <- if (show_pct || show_role) 30 else 0
    avail  <- room_h - head_h            # vertical room left under the header

    code <- list(
      list(txt = toupper(cols[k]), h = 19, bold = TRUE),
      list(txt = rgb_label(cols[k]), h = 15, bold = FALSE),
      list(txt = hsl_label(cols[k]), h = 15, bold = FALSE)
    )[seq_len(max(1, min(3, max_codes)))]
    if (SHOW_NAMES) {
      code <- c(list(list(txt = name_for(cols[k]), h = 26, bold = TRUE, sans = TRUE)),
                code)
    }

    # Keep the longest prefix of (name) hex / RGB / HSL that fits both ways.
    keep <- 0
    used <- 0
    for (j in seq_along(code)) {
      wj <- if (isTRUE(code[[j]]$sans)) {
        graphics::strwidth(code[[j]]$txt, cex = 0.95, font = 2, family = "plexsans")
      } else {
        track_width(code[[j]]$txt, CEX_CODE, TRACK * 0.5, if (code[[j]]$bold) 2 else 1)
      }
      if (wj > room_w || used + code[[j]]$h > avail) break
      used <- used + code[[j]]$h
      keep <- j
    }

    by <- r$y + r$h - tpad - 6
    for (j in rev(seq_len(keep))) {
      e <- code[[j]]
      if (isTRUE(e$sans)) {
        sans(e$txt, r$x + tpad, by - 4, 0.95, fg, font = 2)
      } else {
        tracked(e$txt, r$x + tpad, by, CEX_CODE, fg, TRACK * 0.5, font = if (e$bold) 2 else 1)
      }
      by <- by - e$h
    }
  }
  h
}

# --- the explainer rail ----------------------------------------------------

RAIL_W <- 330

rail_height <- function() 360

draw_rail <- function(x, y, w) {
  ty <- y + 10
  tracked("HOW TO READ THIS", x, ty, CEX_LABEL, INK, TRACK, font = 2)
  ty <- ty + 30

  para <- function(head, body) {
    tracked(head, x, ty, CEX_LABEL * 0.94, MUTED, TRACK)
    ty <<- ty + 20
    for (ln in wrap_sans(body, w, CEX_BODY)) {
      sans(ln, x, ty, CEX_BODY, INK); ty <<- ty + 17
    }
    ty <<- ty + 14
  }

  para("AREA = SHARE",
       paste("Each tile's area is the share of a chart that colour is meant to",
             "carry. The first colour takes about a third, the top three about",
             "two thirds - the 60-30-10 rule generalised to any palette length."))
  para("ROLE",
       paste("Dominant, secondary, support, accent, neutral - assigned by",
             "position, so colour one is always the workhorse and the tail is",
             "for emphasis."))
  para("CODES",
       paste("Hex to paste into R, RGB for screen, HSL for tuning. Bigger tiles",
             "show more; small ones keep the hex only."))
  para("ORDER",
       "Colours read left to right exactly as ltc() returns them.")

  ty <- ty - 6
  graphics::rect(x, ty, x + w, ty + 58, col = "#F1EFE8", border = NA, xpd = NA)
  tracked('ltc("casa_natal")', x + 14, ty + 20, CEX_CODE * 1.05, INK, TRACK * 0.4)
  tracked('ltc("casa_natal", 5, "continuous")', x + 14, ty + 40, CEX_CODE * 1.05, INK, TRACK * 0.4)
}

# --- sections --------------------------------------------------------------

section_of <- function(n) {
  if (n >= 6) "large" else if (n == 5) "five" else if (n == 4) "four" else "trio"
}

SECTIONS <- list(
  large = list(title = "Large",  blurb = "Six colours or more. Room for a full categorical scale.", wide = TRUE),
  five  = list(title = "Five",   blurb = "The workhorses - five distinct colours, the most common shape in the package.", wide = FALSE),
  four  = list(title = "Four",   blurb = "Four colours, for tighter comparisons.", wide = FALSE),
  trio  = list(title = "Trio",   blurb = "Three colours, for two groups and a highlight.", wide = FALSE)
)

ns <- vapply(palettes, length, integer(1))

# The hero card at the top doubles as the key, so it is not repeated below.
# Fall back to the longest palette if casa_natal is ever renamed or removed.
hero <- if ("casa_natal" %in% names(palettes)) "casa_natal" else names(which.max(ns))

by_section <- split(names(palettes), factor(vapply(ns, section_of, character(1)),
                                            levels = names(SECTIONS)))
by_section <- lapply(by_section, function(v) setdiff(v[order(-ns[v], v)], hero))

# --- page geometry ---------------------------------------------------------
MARGIN   <- 44
GAP      <- 22
SEC_HEAD <- 108
COL_GAP  <- 22

content_w <- W - 2 * MARGIN
half_w    <- (content_w - COL_GAP) / 2

# Measure first so the device is exactly as tall as the content.
plan <- list()
cursor <- MARGIN + 26

hero_body_w <- content_w - RAIL_W - 46
hero_h <- max(card_height(length(palettes[[hero]]), TRUE, 3), rail_height())
plan[[length(plan) + 1]] <- list(kind = "hero", y = cursor, h = hero_h)
cursor <- cursor + hero_h + 46

for (sec in names(SECTIONS)) {
  pals <- by_section[[sec]]
  if (!length(pals)) next
  plan[[length(plan) + 1]] <- list(kind = "section", sec = sec, y = cursor,
                                   h = SEC_HEAD, n = length(pals))
  cursor <- cursor + SEC_HEAD
  wide <- ONE_UP || SECTIONS[[sec]]$wide
  if (wide) {
    for (p in pals) {
      hh <- card_height(length(palettes[[p]]), TRUE)
      plan[[length(plan) + 1]] <- list(kind = "card", pal = p, y = cursor,
                                       x = MARGIN, w = content_w, wide = TRUE, h = hh)
      cursor <- cursor + hh + GAP
    }
  } else {
    for (i in seq(1, length(pals), by = 2)) {
      pair <- pals[i:min(i + 1, length(pals))]
      hh <- max(vapply(pair, function(p) card_height(length(palettes[[p]]), FALSE), numeric(1)))
      for (j in seq_along(pair)) {
        plan[[length(plan) + 1]] <- list(
          kind = "card", pal = pair[j], y = cursor,
          x = MARGIN + (j - 1) * (half_w + COL_GAP), w = half_w,
          wide = FALSE, h = hh)
      }
      cursor <- cursor + hh + GAP
    }
  }
  cursor <- cursor + 26
}

H <- cursor + MARGIN

# --- draw ------------------------------------------------------------------
dir.create(dirname(OUT), showWarnings = FALSE, recursive = TRUE)
ragg::agg_png(OUT, width = W, height = H, units = "px", res = RES,
              background = BG)
graphics::par(mar = rep(0, 4), xaxs = "i", yaxs = "i")
graphics::plot.new()
graphics::plot.window(xlim = c(0, W), ylim = c(H, 0), asp = 1)

for (item in plan) {
  if (item$kind == "hero") {
    draw_card(hero, MARGIN, item$y, hero_body_w, wide = TRUE, max_codes = 3)
    draw_rail(MARGIN + hero_body_w + 46, item$y + 12, RAIL_W)
  } else if (item$kind == "section") {
    s <- SECTIONS[[item$sec]]
    sy <- item$y + 46
    sans(s$title, MARGIN, sy, CEX_SECTION, INK, font = 2)
    tw <- graphics::strwidth(s$title, cex = CEX_SECTION, font = 2, family = "plexsans")
    sans(s$blurb, MARGIN + tw + 18, sy + 4, CEX_BIO, MUTED)
    tracked(paste(item$n, if (item$n == 1) "PALETTE" else "PALETTES"),
            W - MARGIN, sy + 4, CEX_LABEL, MUTED, TRACK, adj = 1)
    graphics::segments(MARGIN, item$y + 74, W - MARGIN, item$y + 74,
                       col = RULE, lwd = 1.1, xpd = NA)
  } else {
    draw_card(item$pal, item$x, item$y, item$w, wide = item$wide)
  }
}

grDevices::dev.off()
message("wrote ", OUT, " (", W, "x", H, ", names = ", SHOW_NAMES, ")")
