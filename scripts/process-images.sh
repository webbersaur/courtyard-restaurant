#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/saurus/Documents/workspace/courtyard"
SRC="$ROOT/courtyard images"
HERO="$ROOT/images/hero"
WEB="$ROOT/images/web"
GBP="$ROOT/images/gbp"
MENU="$ROOT/images/menu-source"
LAT=41.29678385133343
LON=72.38119661284904

mkdir -p "$HERO" "$WEB" "$GBP" "$MENU"

# tmp work dir for intermediate renames
TMP="$(mktemp -d)"

# slug pipeline: copy → rename → resize → webp → exif
process () {
  local src="$1" slug="$2" tier="$3" object="$4" caption="$5" keywords="$6"
  local ext="${src##*.}"
  ext=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')
  local base="${slug}"
  local tmpfile="$TMP/${base}.${ext}"
  cp "$src" "$tmpfile"

  # 1) GBP (full quality, renamed, JPG only)
  if [[ "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
    cp "$tmpfile" "$GBP/${base}.jpg"
  fi

  # 2) WEB tier (1200px WebP) for everything except menu sources
  if [[ "$tier" != "menu" ]]; then
    local webcopy="$TMP/web-${base}.${ext}"
    cp "$tmpfile" "$webcopy"
    sips -Z 1200 "$webcopy" >/dev/null
    cwebp -q 85 -mt -quiet "$webcopy" -o "$WEB/${base}.webp"
  fi

  # 3) HERO tier (1920px WebP) only for designated hero photos
  if [[ "$tier" == "hero" ]]; then
    local herocopy="$TMP/hero-${base}.${ext}"
    cp "$tmpfile" "$herocopy"
    sips -Z 1920 "$herocopy" >/dev/null
    cwebp -q 85 -mt -quiet "$herocopy" -o "$HERO/${base}.webp"
  fi

  # 4) Menu source — keep big JPG only
  if [[ "$tier" == "menu" ]]; then
    cp "$tmpfile" "$MENU/${base}.jpg"
  fi

  # 5) EXIF/IPTC/GPS on JPG (gbp) and WebP (web/hero)
  local targets=()
  [[ -f "$GBP/${base}.jpg" ]] && targets+=("$GBP/${base}.jpg")
  [[ -f "$WEB/${base}.webp" ]] && targets+=("$WEB/${base}.webp")
  [[ -f "$HERO/${base}.webp" ]] && targets+=("$HERO/${base}.webp")
  [[ -f "$MENU/${base}.jpg" ]] && targets+=("$MENU/${base}.jpg")

  if [[ ${#targets[@]} -gt 0 ]]; then
    exiftool -overwrite_original -q \
      -GPSLatitude="$LAT" -GPSLatitudeRef=N \
      -GPSLongitude="$LON" -GPSLongitudeRef=W \
      -IPTC:ObjectName="$object" \
      -IPTC:Caption-Abstract="$caption" \
      -XMP:Description="$caption" \
      -XMP:Title="$object" \
      -IPTC:By-line="The Courtyard Restaurant" \
      -Copyright="© The Courtyard Restaurant, Old Saybrook CT" \
      -IPTC:Keywords="$keywords" \
      -XMP:Subject="$keywords" \
      "${targets[@]}" || true
  fi
}

KW_COMMON="Old Saybrook restaurant, Old Saybrook breakfast, Old Saybrook lunch, diner, cash only, Old Saybrook Shopping Center, 105 Elm St, 06475, Connecticut, Courtyard Restaurant"

# Exterior — hero candidates
process "$SRC/IMG_1690.JPG" "courtyard-restaurant-storefront-old-saybrook" "hero" \
  "Courtyard Restaurant storefront in Old Saybrook" \
  "The Courtyard Restaurant storefront on a spring morning, Old Saybrook Shopping Center, 105 Elm St, Old Saybrook CT 06475." \
  "${KW_COMMON}, storefront, exterior, sign, awnings, American flag"

process "$SRC/IMG_1691.JPG" "courtyard-restaurant-spring-old-saybrook" "hero" \
  "Spring view of Courtyard Restaurant in Old Saybrook" \
  "Spring cherry blossoms outside The Courtyard Restaurant in Old Saybrook, Connecticut." \
  "${KW_COMMON}, exterior, spring, cherry blossom, landscaping"

process "$SRC/courtyard front.jpg" "courtyard-restaurant-exterior-old-saybrook-ct" "web" \
  "Courtyard Restaurant exterior, Old Saybrook CT" \
  "The Courtyard Restaurant exterior with red sign and navy awnings, Old Saybrook." \
  "${KW_COMMON}, exterior, winter, sign"

# Interior
process "$SRC/IMG_1686.JPG" "dining-room-booths-courtyard-restaurant" "hero" \
  "Dining room and booths at Courtyard Restaurant" \
  "Pink booths and checkered floor inside The Courtyard Restaurant in Old Saybrook." \
  "${KW_COMMON}, interior, dining room, booths, diner"

process "$SRC/IMG_1687.JPG" "dining-room-checkered-floor-courtyard" "web" \
  "Checkered-floor dining room at Courtyard Restaurant" \
  "Classic checkered floor and booths inside The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, interior, dining room, checkered floor"

process "$SRC/IMG_1688.JPG" "breakfast-counter-courtyard-restaurant-old-saybrook" "hero" \
  "Breakfast counter at The Courtyard Restaurant" \
  "Cook plating breakfast behind the counter at The Courtyard Restaurant in Old Saybrook." \
  "${KW_COMMON}, interior, counter, breakfast, cook, diner"

process "$SRC/IMG_1689.JPG" "friendly-service-courtyard-restaurant" "web" \
  "Friendly service at The Courtyard Restaurant" \
  "Server greeting regulars inside The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, interior, service, server"

# Food
process "$SRC/IMG_1602.jpg" "french-toast-bacon-old-saybrook-breakfast" "web" \
  "French toast with bacon at Courtyard Restaurant" \
  "Plate of French toast dusted with powdered sugar, served with bacon at The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, breakfast, french toast, bacon, food"

process "$SRC/IMG_1603.jpg" "eggs-bacon-home-fries-old-saybrook-breakfast" "web" \
  "Eggs, bacon, home fries, and toast at Courtyard Restaurant" \
  "Classic diner breakfast — over easy eggs, bacon, home fries, and toast at The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, breakfast, eggs, bacon, home fries, toast, food"

process "$SRC/IMG_1604.JPG" "biscuits-and-gravy-courtyard-old-saybrook" "web" \
  "Biscuits and gravy at Courtyard Restaurant" \
  "Biscuits smothered in sausage gravy at The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, breakfast, biscuits and gravy, food"

process "$SRC/IMG_1605.JPG" "biscuits-and-gravy-breakfast-courtyard" "web" \
  "Biscuits and gravy plated for breakfast" \
  "Side of biscuits and gravy at The Courtyard Restaurant, Old Saybrook." \
  "${KW_COMMON}, breakfast, biscuits and gravy, food"

# Brand assets
process "$SRC/Courtyard Logo.png" "courtyard-restaurant-logo" "web" \
  "The Courtyard Restaurant logo" \
  "Logo for The Courtyard Restaurant, Old Saybrook, Connecticut." \
  "${KW_COMMON}, logo, branding"

process "$SRC/cash only.jpg" "cash-only-courtyard-restaurant-old-saybrook" "web" \
  "Cash only sign at The Courtyard Restaurant" \
  "Cash-only window sign at The Courtyard Restaurant in Old Saybrook — we do not accept credit or debit cards." \
  "${KW_COMMON}, cash only, payment, sign"

process "$SRC/Courtyard .png" "how-to-find-courtyard-restaurant-old-saybrook" "web" \
  "How to find Courtyard Restaurant in Old Saybrook Shopping Center" \
  "Directions to The Courtyard Restaurant in the Old Saybrook Shopping Center, with arrows showing the route past Becker's Diamonds and HomeGoods." \
  "${KW_COMMON}, directions, map, how to find, Old Saybrook Shopping Center"

# Logo: also produce a transparent PNG copy at root images/ for the nav
cp "$SRC/Courtyard Logo.png" "$ROOT/images/courtyard-restaurant-logo.png"
# 600px social/OG variant (PNG kept transparent)
sips -Z 600 "$ROOT/images/courtyard-restaurant-logo.png" --out "$ROOT/images/courtyard-restaurant-logo-600.png" >/dev/null

# Menu sources — JPG only, keyworded
i=1
for f in "$SRC"/IMG_1594.JPG "$SRC"/IMG_1595.JPG "$SRC"/IMG_1596.JPG "$SRC"/IMG_1597.JPG "$SRC"/IMG_1598.JPG "$SRC"/IMG_1599.JPG "$SRC"/IMG_1600.JPG; do
  num=$(printf "%02d" "$i")
  process "$f" "menu-source-${num}" "menu" \
    "Courtyard Restaurant menu page ${num}" \
    "Menu reference photograph #${num} for The Courtyard Restaurant, Old Saybrook CT." \
    "${KW_COMMON}, menu reference"
  i=$((i+1))
done

rm -rf "$TMP"
echo "DONE: $(ls "$HERO" | wc -l) hero, $(ls "$WEB" | wc -l) web, $(ls "$GBP" | wc -l) gbp, $(ls "$MENU" | wc -l) menu"
