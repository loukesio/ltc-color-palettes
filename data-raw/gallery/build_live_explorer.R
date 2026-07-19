# Build a fully LIVE palette explorer: all six charts recolour instantly as the
# palette, brightness and colour-vision controls change. Chart geometry is fixed
# and extracted once (map + Voronoi polygons as SVG paths, bubble positions);
# JavaScript paints the fills. Self-contained, static, tiny.
# Output: pkgdown/assets/live-explorer.html

suppressPackageStartupMessages({
  library(dplyr); library(sf); library(rnaturalearth); library(ggvmap)
  library(gapminder); library(jsonlite)
})

pkg <- new.env(); sys.source(file.path("R", "ltc_functions.R"), envir = pkg)
palettes <- pkg$palettes
pal_json <- toJSON(lapply(palettes, toupper), auto_unbox = TRUE)
opts <- paste(sprintf('<option value="%s">%s</option>', names(palettes), names(palettes)),
              collapse = "\n")

# ---- (1) MAP: Europe polygons -> SVG paths + normalised gdp value -----------
eu <- ne_countries(scale = "small", returnclass = "sf") %>%
  filter(continent == "Europe" | name %in% c("Turkey", "Cyprus")) %>%
  filter(name != "Russia") %>%
  mutate(gdp_pc = ifelse(pop_est > 0, gdp_md * 1e6 / pop_est, NA_real_)) %>%
  st_transform(3035) %>%
  st_crop(st_bbox(c(xmin = 2.5e6, xmax = 6.0e6, ymin = 1.4e6, ymax = 5.4e6),
                  crs = st_crs(3035))) %>%
  st_simplify(dTolerance = 9000)
MW <- 240; MH <- 280
bb <- st_bbox(eu)
msx <- function(x) (x - bb["xmin"]) / (bb["xmax"] - bb["xmin"]) * MW
msy <- function(y) MH - (y - bb["ymin"]) / (bb["ymax"] - bb["ymin"]) * MH
ring_str <- function(m) paste0("M", paste0(round(msx(m[, 1]), 1), " ",
                                           round(msy(m[, 2]), 1), collapse = "L"), "Z")
geom_paths <- function(g) {
  if (inherits(g, "MULTIPOLYGON"))
    paste(vapply(g, function(poly) paste(vapply(poly, ring_str, ""), collapse = ""),
                 ""), collapse = "")
  else if (inherits(g, "POLYGON"))
    paste(vapply(g, ring_str, ""), collapse = "")
  else ""
}
map_paths <- vapply(st_geometry(eu), geom_paths, "")
map_v <- pmin(eu$gdp_pc, 90000) / 90000
map_json <- toJSON(data.frame(d = map_paths, v = round(map_v, 3)),
                   auto_unbox = TRUE, na = "null")

# ---- (2) VORONOI: ggvmap cells -> SVG paths ---------------------------------
euc <- gapminder %>% filter(year == 2007, continent == "Europe") %>%
  slice_max(pop, n = 12) %>% mutate(country = as.character(country)) %>%
  arrange(desc(pop))
vm_df <- vm_as_df(voronoi_map(weights = euc$pop, labels = euc$country,
                              clip = clip_circle(), seed = 7))
VS <- 240
vsx <- function(x) x * VS
vsy <- function(y) VS - y * VS
cells <- split(vm_df, factor(vm_df$cell, levels = unique(vm_df$cell)))
vor_paths <- vapply(cells, function(c)
  paste0("M", paste0(round(vsx(c$x), 1), " ", round(vsy(c$y), 1), collapse = "L"), "Z"), "")
vor_json <- toJSON(unname(vor_paths), auto_unbox = TRUE)

# ---- (3) BUBBLE: gapminder 2007 -> normalised positions ---------------------
gap <- gapminder %>% filter(year == 2007) %>%
  mutate(cont = as.integer(factor(continent,
           levels = c("Africa", "Americas", "Asia", "Europe", "Oceania"))) - 1)
lx <- log10(gap$gdpPercap)
BW <- 320; BH <- 240
bcx <- (lx - min(lx)) / (max(lx) - min(lx)) * (BW - 24) + 12
bcy <- BH - ((gap$lifeExp - min(gap$lifeExp)) /
             (max(gap$lifeExp) - min(gap$lifeExp)) * (BH - 24) + 12)
br  <- sqrt(gap$pop) / sqrt(max(gap$pop)) * 15 + 1.5
bub_json <- toJSON(data.frame(cx = round(bcx, 1), cy = round(bcy, 1),
                              r = round(br, 1), c = gap$cont), auto_unbox = TRUE)

# ---- (4) HEATMAP: mtcars correlation, clustered (exactly the gallery plot) ---
cm <- cor(mtcars)
ord <- hclust(as.dist(1 - cm))$order
cm <- cm[ord, ord]
heat_json <- toJSON(list(n = nrow(cm), min = min(cm), max = max(cm),
                         v = round(as.vector(t(cm)), 3)), auto_unbox = TRUE)

tmpl <- r"---(<!doctype html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>ltc live palette explorer</title>
<style>
  :root{--ink:#1A1A1A;--sub:#6B6B6B;--line:#E2E2E2;--bg:#fff;--chip:#F3F3F3;}
  @media (prefers-color-scheme:dark){:root{--ink:#ECECEC;--sub:#9A9A9A;--line:#333;--bg:#141414;--chip:#222;}}
  *{box-sizing:border-box;}
  body{margin:0;background:var(--bg);color:var(--ink);font-family:"IBM Plex Sans",-apple-system,Segoe UI,Roboto,sans-serif;}
  .wrap{max-width:1000px;margin:0 auto;padding:30px 20px 70px;}
  h1{font-size:1.6rem;margin:0 0 2px;}
  .lede{color:var(--sub);margin:0 0 20px;line-height:1.5;}
  .topbar{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:14px;}
  button.nav{font-size:1rem;padding:8px 12px;border:1px solid var(--line);border-radius:8px;background:var(--bg);color:var(--ink);cursor:pointer;}
  button.nav:hover{background:var(--chip);}
  select{font-family:"IBM Plex Mono",monospace;font-size:1rem;padding:8px 11px;border:1px solid var(--line);border-radius:8px;background:var(--bg);color:var(--ink);min-width:200px;}
  .controls{display:flex;gap:24px;flex-wrap:wrap;align-items:flex-end;padding:12px 15px;border:1px solid var(--line);border-radius:12px;margin-bottom:14px;}
  .ctl label{display:block;font-weight:700;font-size:.78rem;margin-bottom:6px;}
  input[type=range]{width:180px;accent-color:var(--ink);}
  .seg{display:inline-flex;border:1px solid var(--line);border-radius:8px;overflow:hidden;}
  .seg button{font-family:inherit;font-size:.78rem;padding:7px 10px;border:0;background:var(--bg);color:var(--sub);cursor:pointer;}
  .seg button.on{background:var(--ink);color:var(--bg);}
  .bval{font-family:"IBM Plex Mono",monospace;font-size:.78rem;color:var(--sub);}
  .swrow{margin:0 0 12px;}
  .swlab{font-size:.72rem;color:var(--sub);font-weight:700;display:block;margin-bottom:4px;}
  .swatches{display:flex;border-radius:10px;overflow:hidden;border:1px solid var(--line);margin:0 0 18px;}
  .sw{flex:1;height:48px;display:flex;align-items:flex-end;justify-content:center;cursor:pointer;}
  .sw span{font-family:"IBM Plex Mono",monospace;font-size:.58rem;padding:3px 0 4px;}
  .toast{position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:var(--ink);color:var(--bg);padding:7px 15px;border-radius:18px;font-size:.82rem;opacity:0;transition:opacity .2s;pointer-events:none;}
  .toast.show{opacity:1;}
  .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;}
  .card{border:1px solid var(--line);border-radius:12px;padding:11px;}
  .card h3{font-size:.8rem;color:var(--sub);font-weight:700;margin:0 0 7px;}
  svg{width:100%;height:auto;display:block;background:var(--bg);}
  @media (max-width:820px){.grid{grid-template-columns:repeat(2,1fr);}}
  @media (max-width:520px){.grid{grid-template-columns:1fr;}}
</style></head><body>
<div class="wrap">
  <h1 id="pname">—</h1>
  <p class="lede">Every ltc palette across six charts — recoloured <b>live</b>. Change the palette,
     darken or brighten it, or simulate colour-vision deficiency, and every chart repaints instantly.</p>

  <div class="topbar">
    <button class="nav" id="prev">&larr;</button>
    <select id="sel">__OPTS__</select>
    <button class="nav" id="next">&rarr;</button>
  </div>

  <div class="controls">
    <div class="ctl"><label for="b">Brightness <span class="bval" id="bv"></span></label>
      <input type="range" id="b" min="-50" max="50" step="10" value="0"></div>
    <div class="ctl"><label>Colour vision</label>
      <div class="seg" id="cvd">
        <button data-t="normal" class="on">Normal</button>
        <button data-t="deuteranopia">Deuter.</button>
        <button data-t="protanopia">Protan.</button>
        <button data-t="tritanopia">Tritan.</button>
      </div></div>
  </div>

  <div class="swatches" id="sw"></div>
  <div class="toast" id="toast"></div>

  <div class="grid">
    <div class="card"><h3>Map · choropleth</h3><svg id="map" viewBox="0 0 240 280"></svg></div>
    <div class="card"><h3>ggvmap · Voronoi</h3><svg id="vor" viewBox="0 0 240 240"></svg></div>
    <div class="card"><h3>Heatmap</h3><svg id="heat" viewBox="0 0 240 240"></svg></div>
    <div class="card"><h3>Bubble</h3><svg id="bub" viewBox="0 0 320 240"></svg></div>
    <div class="card"><h3>Barplot</h3><svg id="bar" viewBox="0 0 240 240"></svg></div>
    <div class="card"><h3>Streamgraph</h3><svg id="str" viewBox="0 0 300 240"></svg></div>
  </div>
</div>

<script>
const PALETTES=__PALETTES__, MAP=__MAP__, VOR=__VOR__, BUB=__BUB__, HEAT=__HEAT__;
const state={pal:Object.keys(PALETTES)[0],bright:0,cvd:"normal"};
const NS="http://www.w3.org/2000/svg";
const h2r=h=>{h=h.replace("#","");return [parseInt(h.slice(0,2),16),parseInt(h.slice(2,4),16),parseInt(h.slice(4,6),16)];};
const cl=x=>Math.max(0,Math.min(255,x));
const r2h=r=>"#"+r.map(x=>cl(Math.round(x)).toString(16).padStart(2,"0")).join("");
function ramp(cols,t){const rgb=cols.map(h2r),n=rgb.length-1;const s=Math.max(0,Math.min(0.99999,t))*n,i=Math.floor(s),f=s-i;const a=rgb[i],b=rgb[Math.min(i+1,n)];return [a[0]+(b[0]-a[0])*f,a[1]+(b[1]-a[1])*f,a[2]+(b[2]-a[2])*f];}
function rampK(cols,K){const o=[];for(let i=0;i<K;i++)o.push(ramp(cols,K===1?0:i/(K-1)));return o;}
function bright(rgb,a){if(a<0){const k=1+a/100;return rgb.map(x=>x*k);}if(a>0){const k=a/100;return rgb.map(x=>x+(255-x)*k);}return rgb;}
const CVD={normal:null,deuteranopia:[[0.625,0.375,0],[0.70,0.30,0],[0,0.30,0.70]],protanopia:[[0.567,0.433,0],[0.558,0.442,0],[0,0.242,0.758]],tritanopia:[[0.95,0.05,0],[0,0.433,0.567],[0,0.475,0.525]]};
function cvd(rgb,t){const m=CVD[t];if(!m)return rgb;return [0,1,2].map(i=>m[i][0]*rgb[0]+m[i][1]*rgb[1]+m[i][2]*rgb[2]);}
const fx=rgb=>r2h(cvd(bright(rgb,state.bright),state.cvd));
function textColor(hex){const c=hex.replace("#","");const r=parseInt(c.slice(0,2),16),g=parseInt(c.slice(2,4),16),b=parseInt(c.slice(4,6),16);return (0.299*r+0.587*g+0.114*b)>150?"#1A1A1A":"#fff";}
const toast=document.getElementById("toast");let toastT;
function flash(m){toast.textContent=m;toast.classList.add("show");clearTimeout(toastT);toastT=setTimeout(()=>toast.classList.remove("show"),1000);}
function copy(t){navigator.clipboard.writeText(t).then(()=>flash("Copied "+t));}
function fillBar(el,colors){el.innerHTML="";colors.forEach(hex=>{const H=hex.toUpperCase();const d=document.createElement("div");d.className="sw";d.style.background=hex;const s=document.createElement("span");s.textContent=H;s.style.color=textColor(hex);d.appendChild(s);d.onclick=()=>copy(H);el.appendChild(d);});}

// ---- build fixed geometry once ----
const map=document.getElementById("map");
MAP.forEach(f=>{const p=document.createElementNS(NS,"path");p.setAttribute("d",f.d);p.setAttribute("stroke","#fff");p.setAttribute("stroke-width",0.4);map.appendChild(p);f.el=p;});
const vor=document.getElementById("vor");
VOR.forEach((d,i)=>{const p=document.createElementNS(NS,"path");p.setAttribute("d",d);p.setAttribute("stroke","#fff");p.setAttribute("stroke-width",1.4);vor.appendChild(p);VOR[i]={d,el:p};});
const heat=document.getElementById("heat"),HN=HEAT.n,hcs=240/HN,hc=[];
for(let i=0;i<HN;i++)for(let j=0;j<HN;j++){const r=document.createElementNS(NS,"rect");r.setAttribute("x",j*hcs);r.setAttribute("y",i*hcs);r.setAttribute("width",hcs);r.setAttribute("height",hcs);r.setAttribute("stroke","#fff");r.setAttribute("stroke-width",0.8);heat.appendChild(r);hc.push({el:r,t:(HEAT.v[i*HN+j]-HEAT.min)/(HEAT.max-HEAT.min)});}
const bub=document.getElementById("bub");
BUB.forEach(d=>{const c=document.createElementNS(NS,"circle");c.setAttribute("cx",d.cx);c.setAttribute("cy",d.cy);c.setAttribute("r",d.r);c.setAttribute("stroke","#fff");c.setAttribute("stroke-width",0.6);c.setAttribute("opacity",0.9);bub.appendChild(c);d.el=c;});
const bar=document.getElementById("bar"),NBAR=10,barEls=[];
for(let i=0;i<NBAR;i++){const w=(NBAR-i)/NBAR*230;const r=document.createElementNS(NS,"rect");r.setAttribute("x",0);r.setAttribute("y",i*23+3);r.setAttribute("width",w);r.setAttribute("height",18);r.setAttribute("rx",2);bar.appendChild(r);barEls.push(r);}
// streamgraph: 6 centred ribbons, fixed geometry
const str=document.getElementById("str");
// streamgraph rebuilt per palette: min(n,6) ribbons, discrete palette colours,
// centred silhouette auto-scaled to the card (matches the gallery plot)
function renderStream(cols){
  const k=Math.min(cols.length,6),SN=60,W=300,cy=120,sv=[];
  for(let j=0;j<k;j++){const c=[];for(let t=0;t<SN;t++){const x=1+t*(9/(SN-1));c.push(Math.max(0.25,2+1.4*Math.sin(x/1.5+(j+1))+0.8*Math.cos(x/0.9+(j+1)*2)));}sv.push(c);}
  let amax=1e-6;const rib=[];
  for(let j=0;j<k;j++){const top=[],bot=[];for(let t=0;t<SN;t++){let base=0;for(let m=0;m<j;m++)base+=sv[m][t];let tot=0;for(let m=0;m<k;m++)tot+=sv[m][t];const off=-tot/2,yb=off+base,yt=off+base+sv[j][t];amax=Math.max(amax,Math.abs(yb),Math.abs(yt));top.push([t,yt]);bot.push([t,yb]);}rib.push({top,bot});}
  const S=110/amax,PX=t=>t*(W/(SN-1)),PY=y=>cy-y*S;
  str.innerHTML="";
  rib.forEach((r,j)=>{const tp=r.top.map(p=>PX(p[0]).toFixed(1)+" "+PY(p[1]).toFixed(1));const bt=r.bot.map(p=>PX(p[0]).toFixed(1)+" "+PY(p[1]).toFixed(1)).reverse();const p=document.createElementNS(NS,"path");p.setAttribute("d","M"+tp.join("L")+"L"+bt.join("L")+"Z");p.setAttribute("fill",fx(h2r(cols[j])));str.appendChild(p);});
}

function render(){
  const cols=PALETTES[state.pal];
  fillBar(document.getElementById("sw"), cols.map(h=>fx(h2r(h))));
  MAP.forEach(f=>f.el.setAttribute("fill", f.v==null?"#EDEDED":fx(ramp(cols,f.v))));
  const vk=rampK(cols,VOR.length);VOR.forEach((c,i)=>c.el.setAttribute("fill",fx(vk[i])));
  hc.forEach(c=>c.el.setAttribute("fill",fx(ramp(cols,c.t))));
  const c5=rampK(cols,5);BUB.forEach(d=>d.el.setAttribute("fill",fx(c5[d.c])));
  barEls.forEach((el,i)=>{const on=i<cols.length;el.style.display=on?"":"none";if(on)el.setAttribute("fill",fx(h2r(cols[i])));});
  renderStream(cols);
  document.getElementById("pname").textContent=state.pal;
  document.getElementById("bv").textContent=state.bright===0?"(original)":(state.bright>0?"+"+state.bright:""+state.bright);
}
const sel=document.getElementById("sel");
sel.addEventListener("change",e=>{state.pal=e.target.value;render();});
document.getElementById("b").addEventListener("input",e=>{state.bright=+e.target.value;render();});
document.querySelectorAll("#cvd button").forEach(b=>b.addEventListener("click",()=>{document.querySelectorAll("#cvd button").forEach(x=>x.classList.remove("on"));b.classList.add("on");state.cvd=b.dataset.t;render();}));
function step(d){let i=(sel.selectedIndex+d+sel.options.length)%sel.options.length;sel.selectedIndex=i;state.pal=sel.value;render();}
document.getElementById("prev").onclick=()=>step(-1);
document.getElementById("next").onclick=()=>step(1);
render();
</script>
</body></html>
)---"

html <- tmpl
for (kv in list(c("__OPTS__", opts), c("__PALETTES__", pal_json),
                c("__MAP__", map_json), c("__VOR__", vor_json), c("__BUB__", bub_json),
                c("__HEAT__", heat_json)))
  html <- gsub(kv[1], kv[2], html, fixed = TRUE)

out <- file.path("pkgdown", "assets", "palette-explorer.html")
dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
writeLines(html, out)
message("Wrote ", out, " (", round(file.info(out)$size / 1024, 1), " KB)")
