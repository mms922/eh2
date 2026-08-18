#!/bin/bash
# Rebuilds the EH2 slides website: copies the current deck PDFs into slides/
# and regenerates index.html from decks.tsv.
#
#   decks.tsv columns:  number <TAB> unit <TAB> title <TAB> citation <TAB> source path
#   Source paths are relative to the "econ history" folder.
#
# Usage:  ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
COURSE_DIR="$(cd .. && pwd)"

mkdir -p slides
echo "Copying decks..."
while IFS=$'\t' read -r num unit title cite src; do
  [ -z "${num:-}" ] && continue
  if [ -f "$COURSE_DIR/$src" ]; then
    cp "$COURSE_DIR/$src" "slides/$(basename "$src")"
  else
    echo "  MISSING: $src" >&2
  fi
done < decks.tsv

STAMP=$(date "+%d %b %Y")

{
cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Historia Economica Geral II - Slides</title>
<style>
  :root{
    --bg:#fbfaf7; --panel:#ffffff; --ink:#1a1a1a; --muted:#6b6b6b;
    --line:#e4e0d8; --accent:#7a1f1f; --accent-soft:#f3ece9;
  }
  @media (prefers-color-scheme: dark){
    :root{ --bg:#14161a; --panel:#1b1e24; --ink:#e9e6e1; --muted:#9aa0a8;
           --line:#2c313a; --accent:#e0a3a3; --accent-soft:#252a32; }
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);
    font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Georgia,serif;
    line-height:1.55;-webkit-font-smoothing:antialiased}
  .wrap{max-width:840px;margin:0 auto;padding:48px 20px 80px}
  header{border-bottom:2px solid var(--accent);padding-bottom:20px;margin-bottom:8px}
  h1{font-size:1.9rem;margin:0 0 6px;letter-spacing:-.01em}
  .sub{color:var(--muted);font-size:1rem;margin:0}
  .note{color:var(--muted);font-size:.9rem;margin:18px 0 28px}
  .unit{font-size:.72rem;letter-spacing:.12em;text-transform:uppercase;
    color:var(--muted);margin:34px 0 10px;font-weight:600;
    font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
  ul{list-style:none;margin:0;padding:0}
  li{border-bottom:1px solid var(--line)}
  a.row{display:flex;gap:16px;align-items:baseline;padding:13px 10px;
    text-decoration:none;color:inherit;border-radius:6px}
  a.row:hover{background:var(--accent-soft)}
  .n{flex:0 0 2.1em;text-align:right;color:var(--accent);font-weight:700;
    font-variant-numeric:tabular-nums;font-size:.95rem}
  .t{flex:1 1 auto}
  .t b{font-weight:600;display:block}
  .t span{color:var(--muted);font-size:.88rem}
  .pdf{flex:0 0 auto;color:var(--muted);font-size:.72rem;letter-spacing:.08em;
    font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
  li.tbd{padding:13px 10px;display:flex;gap:16px;align-items:baseline;color:var(--muted)}
  li.tbd .n{color:var(--muted)}
  footer{margin-top:48px;color:var(--muted);font-size:.85rem;
    border-top:1px solid var(--line);padding-top:16px}
</style>
</head>
<body>
<div class="wrap">
<header>
  <h1>Historia Economica Geral II</h1>
  <p class="sub">FGV EPGE &middot; Lecture slides</p>
</header>
<p class="note">Click a class to open the slides. Nothing here needs a login.</p>
HEAD

prev_unit=""
open_list=0
declare -a extra_after
extra_after[12]="13-14|Guest lectures (Alexandre Portugal)
15|A1 review"
extra_after[20]="21-22|Guest lectures (Alexandre Portugal)"

while IFS=$'\t' read -r num unit title cite src; do
  [ -z "${num:-}" ] && continue
  base=$(basename "$src")
  if [ "$unit" != "$prev_unit" ]; then
    [ "$open_list" -eq 1 ] && echo "</ul>"
    echo "<div class=\"unit\">$unit</div>"
    echo "<ul>"; open_list=1
    prev_unit="$unit"
  elif [ "$open_list" -eq 0 ]; then
    echo "<ul>"; open_list=1
  fi
  echo "<li><a class=\"row\" href=\"slides/$base\">"
  echo "  <span class=\"n\">$num</span>"
  echo "  <span class=\"t\"><b>$title</b><span>$cite</span></span>"
  echo "  <span class=\"pdf\">PDF</span></a></li>"
  if [ -n "${extra_after[$num]:-}" ]; then
    echo "</ul>"; open_list=0
    echo "<ul>"
    while IFS='|' read -r xn xt; do
      [ -z "$xn" ] && continue
      echo "<li class=\"tbd\"><span class=\"n\">$xn</span><span class=\"t\">$xt</span></li>"
    done <<< "${extra_after[$num]}"
    echo "</ul>"
  fi
done < decks.tsv
[ "$open_list" -eq 1 ] && echo "</ul>"

cat <<TAIL
<div class="unit">End of term</div>
<ul><li class="tbd"><span class="n">26-29</span><span class="t">Student presentations</span></li></ul>
<footer>Last updated $STAMP</footer>
</div>
</body>
</html>
TAIL
} > index.html

echo "Built index.html with $(grep -c 'class="row"' index.html) decks."
