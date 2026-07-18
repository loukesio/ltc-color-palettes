# Build a self-contained interactive palette explorer (single HTML file).
#
# Features:
#   - dropdown + prev/next arrows to step through palettes
#   - a 6-chart preview card per palette (map, voronoi, heatmap, bubble,
#     barplot, streamgraph)
#   - a brightness slider (darken <-> brighten) driven by the SAME colorspace
#     logic as adjust_ltc(), showing the exact adjusted hex codes
#   - a colour-vision-deficiency toggle (Normal / Deuteranopia / Protanopia /
#     Tritanopia) applied to the (possibly adjusted) swatches
#   - click any swatch to copy its current hex
#
# All hexes are pre-computed in R so they match the package functions exactly.
# Output: pkgdown/palette-explorer.html   (regenerate after adding a palette)

suppressPackageStartupMessages(library(colorspace))
pkg <- new.env()
sys.source(file.path("R", "ltc_functions.R"), envir = pkg)
palettes <- pkg$palettes

groups <- list(
  "Large (>5)" = c("hat", "reading", "luminaries", "lincoln", "minou",
                   "expevo", "casa_natal"),
  "Heatmap"    = c("heatmap0", "heatmap1", "heatmap2", "heatmap3"),
  "Dark"       = c("dora", "kiss", "franscoise", "alger", "pantone23",
                   "maya", "shuggie", "midnight"),
  "Pastel"     = c("paloma", "olga", "mterese", "gaby", "ploen",
                   "seafarer", "sylvie", "fernande", "remains"),
  "Trio"       = c("trio1", "trio2", "trio3", "trio4")
)
leftover <- setdiff(names(palettes), unlist(groups))
if (length(leftover)) groups[["Other"]] <- leftover

b64 <- function(path) {
  raw <- readBin(path, "raw", file.info(path)$size)
  paste0("data:image/png;base64,", jsonlite::base64_enc(raw))
}

# brightness levels, adjusted the same way as adjust_ltc()
levels_pct <- c(-40, -20, 0, 20, 40)
adj <- function(pal, L) {
  if (L < 0) colorspace::darken(pal, abs(L) / 100)
  else if (L > 0) colorspace::lighten(pal, L / 100)
  else pal
}
cvd_all <- function(hex) list(
  normal       = toupper(unname(hex)),
  deuteranopia = toupper(unname(colorspace::deutan(hex))),
  protanopia   = toupper(unname(colorspace::protan(hex))),
  tritanopia   = toupper(unname(colorspace::tritan(hex)))
)

recs <- lapply(names(palettes), function(nm) {
  pal <- palettes[[nm]]
  img <- file.path("man", "figures", "previews", paste0(nm, ".png"))
  by_level <- lapply(levels_pct, function(L) cvd_all(adj(pal, L)))
  names(by_level) <- as.character(levels_pct)
  list(
    name    = nm,
    cat     = names(groups)[vapply(groups, function(g) nm %in% g, logical(1))][1],
    img     = if (file.exists(img)) b64(img) else "",
    levels  = levels_pct,
    byLevel = by_level
  )
})
data_json <- jsonlite::toJSON(recs, auto_unbox = TRUE)

opts_html <- paste(vapply(names(groups), function(g) {
  items <- paste0(sprintf('<option value="%s">%s</option>', groups[[g]], groups[[g]]),
                  collapse = "\n")
  sprintf('<optgroup label="%s">\n%s\n</optgroup>', g, items)
}, character(1)), collapse = "\n")

tmpl <- r"---(<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ltc palette explorer</title>
<style>
  :root { --ink:#1A1A1A; --subtle:#6B6B6B; --line:#E2E2E2; --bg:#ffffff; --chip:#F3F3F3; }
  @media (prefers-color-scheme: dark) {
    :root { --ink:#ECECEC; --subtle:#9A9A9A; --line:#333; --bg:#141414; --chip:#222; }
  }
  * { box-sizing:border-box; }
  body { margin:0; background:var(--bg); color:var(--ink);
         font-family:"IBM Plex Sans", -apple-system, Segoe UI, Roboto, sans-serif; }
  .wrap { max-width:1040px; margin:0 auto; padding:34px 22px 80px; }
  h1 { font-weight:700; font-size:1.8rem; margin:0 0 2px; }
  .lede { color:var(--subtle); margin:0 0 24px; line-height:1.5; }
  .topbar { display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:22px; }
  select { font-family:"IBM Plex Mono", monospace; font-size:1rem; padding:9px 12px;
           border:1px solid var(--line); border-radius:8px; background:var(--bg);
           color:var(--ink); min-width:230px; }
  button.nav { font-size:1rem; padding:8px 13px; border:1px solid var(--line);
               border-radius:8px; background:var(--bg); color:var(--ink); cursor:pointer; }
  button.nav:hover { background:var(--chip); }
  .name { font-family:"IBM Plex Mono", monospace; font-weight:700; font-size:1.5rem; margin:0; }
  .cat { color:var(--subtle); font-size:.9rem; margin:1px 0 16px; }
  .controls { display:flex; gap:26px; flex-wrap:wrap; align-items:flex-end;
              padding:14px 16px; border:1px solid var(--line); border-radius:12px;
              margin-bottom:14px; }
  .ctl label { display:block; font-weight:700; font-size:.8rem; margin-bottom:7px; }
  input[type=range] { width:200px; accent-color:var(--ink); }
  .seg { display:inline-flex; border:1px solid var(--line); border-radius:8px; overflow:hidden; }
  .seg button { font-family:inherit; font-size:.82rem; padding:7px 11px; border:0;
                background:var(--bg); color:var(--subtle); cursor:pointer; }
  .seg button.on { background:var(--ink); color:var(--bg); }
  .bval { font-family:"IBM Plex Mono", monospace; font-size:.8rem; color:var(--subtle); }
  .swatches { display:flex; border-radius:10px; overflow:hidden; border:1px solid var(--line);
              margin-bottom:6px; }
  .swatch { flex:1; height:66px; display:flex; align-items:flex-end; justify-content:center;
            cursor:pointer; }
  .swatch span { font-family:"IBM Plex Mono", monospace; font-size:.6rem; padding:3px 0 4px; }
  .hint { color:var(--subtle); font-size:.78rem; margin:0 0 20px; }
  img.preview { width:100%; border:1px solid var(--line); border-radius:12px; background:#fff; }
  .imgnote { color:var(--subtle); font-size:.76rem; margin:8px 0 0; }
  .toast { position:fixed; bottom:24px; left:50%; transform:translateX(-50%);
           background:var(--ink); color:var(--bg); padding:8px 16px; border-radius:20px;
           font-size:.85rem; opacity:0; transition:opacity .2s; pointer-events:none; }
  .toast.show { opacity:1; }
</style>
</head>
<body>
<div class="wrap">
  <h1>ltc palette explorer</h1>
  <p class="lede">Every palette in the <b>ltc</b> package across six chart types.
     Step through them, darken or brighten the colours, and check how they hold up
     under colour-vision deficiency.</p>

  <div class="topbar">
    <button class="nav" id="prev" title="Previous">&larr;</button>
    <select id="sel">__OPTS__</select>
    <button class="nav" id="next" title="Next">&rarr;</button>
  </div>

  <p class="name" id="pname"></p>
  <p class="cat" id="pcat"></p>

  <div class="controls">
    <div class="ctl">
      <label for="bright">Brightness <span class="bval" id="bval"></span></label>
      <input type="range" id="bright" min="0" max="4" step="1" value="2">
    </div>
    <div class="ctl">
      <label>Colour vision</label>
      <div class="seg" id="cvd">
        <button data-t="normal" class="on">Normal</button>
        <button data-t="deuteranopia">Deuteranopia</button>
        <button data-t="protanopia">Protanopia</button>
        <button data-t="tritanopia">Tritanopia</button>
      </div>
    </div>
  </div>

  <div class="swatches" id="pswatch"></div>
  <p class="hint">Click a swatch to copy its hex. Brightness matches <code>adjust_ltc()</code>.</p>

  <img class="preview" id="pimg" alt="palette preview">
  <p class="imgnote">Charts show the palette at its original colours; the swatches above reflect the brightness and colour-vision settings.</p>
</div>
<div class="toast" id="toast"></div>

<script>
const DATA = __DATA__;
const byName = Object.fromEntries(DATA.map(d => [d.name, d]));
const sel = document.getElementById("sel");
const toast = document.getElementById("toast");
const state = { bIdx: 2, cvd: "normal" };
let toastT;
function flash(m){ toast.textContent=m; toast.classList.add("show");
  clearTimeout(toastT); toastT=setTimeout(()=>toast.classList.remove("show"),1100); }
function copy(t){ navigator.clipboard.writeText(t).then(()=>flash("Copied "+t)); }
function textColor(hex){ const c=hex.replace("#","");
  const r=parseInt(c.substr(0,2),16),g=parseInt(c.substr(2,2),16),b=parseInt(c.substr(4,2),16);
  return (0.299*r+0.587*g+0.114*b) > 150 ? "#1A1A1A" : "#ffffff"; }
function currentCols(d){
  const lvl = String(d.levels[state.bIdx]);
  return d.byLevel[lvl][state.cvd];
}
function renderSwatches(){
  const d = byName[sel.value];
  const cols = currentCols(d);
  const sw = document.getElementById("pswatch"); sw.innerHTML = "";
  cols.forEach(hex => {
    const el = document.createElement("div");
    el.className = "swatch"; el.style.background = hex;
    el.innerHTML = "<span style='color:"+textColor(hex)+"'>"+hex+"</span>";
    el.onclick = () => copy(hex);
    sw.appendChild(el);
  });
  const lv = d.levels[state.bIdx];
  document.getElementById("bval").textContent =
    lv === 0 ? "(original)" : (lv > 0 ? "+"+lv+" lighter" : lv+" darker");
}
function render(){
  const d = byName[sel.value];
  document.getElementById("pname").textContent = d.name;
  document.getElementById("pcat").textContent = d.cat + " palette";
  document.getElementById("pimg").src = d.img;
  renderSwatches();
}
document.getElementById("bright").addEventListener("input", e => {
  state.bIdx = +e.target.value; renderSwatches();
});
document.querySelectorAll("#cvd button").forEach(b => b.addEventListener("click", () => {
  document.querySelectorAll("#cvd button").forEach(x => x.classList.remove("on"));
  b.classList.add("on"); state.cvd = b.dataset.t; renderSwatches();
}));
function step(delta){
  let i = sel.selectedIndex + delta;
  i = (i + sel.options.length) % sel.options.length;
  while (sel.options[i].disabled) i = (i + delta + sel.options.length) % sel.options.length;
  sel.selectedIndex = i; render();
}
document.getElementById("prev").onclick = () => step(-1);
document.getElementById("next").onclick = () => step(1);
sel.addEventListener("change", render);
render();
</script>
</body>
</html>
)---"

html <- gsub("__DATA__", data_json,
             gsub("__OPTS__", opts_html, tmpl, fixed = TRUE), fixed = TRUE)

dir.create("pkgdown", showWarnings = FALSE)
writeLines(html, file.path("pkgdown", "palette-explorer.html"))
message("Wrote pkgdown/palette-explorer.html (",
        round(file.info("pkgdown/palette-explorer.html")$size / 1e6, 2), " MB, ",
        length(recs), " palettes)")
