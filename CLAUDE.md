# CLAUDE.md

Guidance for Claude Code when working with this repo.

## Project

Static single-page website for **The Courtyard Restaurant**, a cash-only breakfast & lunch diner at 105 Elm St #1, Old Saybrook, CT 06475 (Old Saybrook Shopping Center). Phone 860-388-1821. Open Mon–Sat 6:00 AM – 2:00 PM, Sun 6:00 AM – 1:00 PM. Geo: 41.29678385133343, -72.38119661284904.

SEO goals: rank for "restaurant in Old Saybrook," "lunch in Old Saybrook," "Old Saybrook breakfast specials."

## Dev

```bash
python3 -m http.server 8080
# then open http://localhost:8080
```

No build step. Deploy via Vercel (`vercel` / `vercel --prod`).

## Layout

- `index.html` — single page, all sections.
- `css/critical.css` — above-fold tokens, header, hero.
- `css/styles.css` — everything below the fold.
- `js/main.js` — mobile nav, IntersectionObserver, specials fetch.
- `data/specials.json` — change-portal target (see below).
- `images/hero/` — 1920px WebP (storefront, counter, booths used as hero candidates).
- `images/web/` — 1200px WebP (everything used inline on the page).
- `images/gbp/` — full-size JPG originals with GPS/IPTC/EXIF for Google Business Profile uploads.
- `images/menu-source/` — reference photos of the printed menu, JPG.
- `scripts/process-images.sh` — re-runnable image pipeline (sips → cwebp → exiftool).

## Change-portal integration

This site uses the **HTML section replacement** pattern from change-portal (`/Users/saurus/Documents/workspace/change-portal/`), matching the wiring on `webber/change-portal-test.html`. The portal commits new HTML directly between named markers in `index.html` via the `update_html_section` deploy action.

Currently wired sections (look for `<!-- section:NAME -->...<!-- /section:NAME -->` blocks):

- `specials` — daily specials, fed from owner-submitted updates

Pattern for adding new portal-targetable sections later:
1. Wrap the editable HTML in `<!-- section:NAME -->...<!-- /section:NAME -->`
2. Add `data-section="NAME"` to the outer wrapper for identification

**Owner login corner:** A 44×44px transparent `<a>` in the bottom-right of the footer points to `portal.webbersaurus.com/client/login.html?client=courtyard-restaurant`. Owner taps the corner to log in and submit changes.

**Slug:** `courtyard-restaurant` (used in the owner-login URL; must match the eventual Supabase `clients` row).

## Pending onboarding (blocked on prereqs)

Before running `change-portal/scripts/new-client.js`, we still need:
- Site live at `courtyardoldsaybrook.com` (confirmed domain; site not deployed yet)
- GitHub repo with `main` branch (local repo initialized; remote not yet created)

When ready, run from the change-portal repo:
```bash
node scripts/new-client.js --slug courtyard-restaurant \
  --domain courtyardoldsaybrook.com \
  --github-repo <owner>/<repo> \
  --owner-email jaramillo2898@gmail.com \
  --primary "#B82828" \
  --clean-urls
supabase db push
# then walk through the generated checklist
```

## Conventions

- Image filenames: lowercase, hyphenated, keyword-rich (e.g., `breakfast-counter-courtyard-restaurant-old-saybrook.webp`).
- Cash-only: every page section and metadata should mention this — it's a customer experience-critical fact, not just SEO.
- "How to find us" section is load-bearing — many first-time customers can't find the building. Don't trim the directions.
- Mobile-first responsive, breakpoints at 640px and 1024px.
