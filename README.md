# SENSE Lab website

The website of the **Software Engineering and System Engineering (SENSE) Lab** at the
University of Waterloo (led by Prof. Weiyi Shang). It is a static site generated with
**[Eleventy](https://www.11ty.dev/) + [WebC](https://www.11ty.dev/docs/languages/webc/)**
and deployed to GitHub Pages.

The design is a polished monochrome theme; the site is **component-based and data-driven**
(no duplicated markup across pages). If you've seen the all-static, hand-duplicated HTML
version on the `main` branch's history — this branch is the deduplicated framework version
of the same design.

---

## Quick start

```sh
npm install          # install deps (Eleventy + WebC plugin)
npm run serve        # dev server with live reload at http://localhost:8080
npm run build        # production build into _site/
```

Requires Node (LTS). Output goes to `_site/` (git-ignored). CI (`.github/workflows/github-pages.yml`)
runs `npm ci` + `npm run build` and publishes `_site/` to GitHub Pages on push to `main`.

> `playwright` is a devDependency used only for local visual checks (screenshots / DOM
> probes). The build itself does not use it.

---

## Project layout

```
eleventy.config.js          # Eleventy config: input=src, WebC plugin, passthrough copies
src/
  index.webc                # "/"          (home: hero + about)
  research.webc             # "/research/"
  publications.webc         # "/publications/"
  tools.webc                # "/tools/"
  people.webc               # "/people/"
  teaching.webc             # "/teaching/"
  contact.webc              # "/contact/"
  weiyi_shang.webc          # "/weiyi_shang/" (PI profile page)
  _data/                    # global data (see "Data" below)
  _includes/
    layouts/base.webc       # the one layout: <head>, theme tokens, global CSS, header, footer
    components/             # reusable site-* components + tag overrides (button, footer)
upload/                     # the original uploaded static site — REFERENCE ONLY, not built
  css/style.css             #   the source design system the components were ported from
  images/                   #   site images (passed through to /images)
  *.html                    #   original static pages (source of content; not served)
pubs/                       # publication PDFs (passed through to /pubs/)
_site/                      # build output (git-ignored)
```

Pages live at `src/*.webc` and route by filename (`research.webc` → `/research/`).
There is a global `layout: layouts/base` (set in `eleventy.config.js`), so pages don't
declare a layout.

---

## How it works

### Layout & theme (`src/_includes/layouts/base.webc`)

`base.webc` owns everything global: the `<head>`, the monochrome theme tokens
(`--color-*`), typography (Inter + Plus Jakarta Sans), the **layout system**, the header,
and the footer. CSS lives in `@layer` blocks (`theme`, `reset`, `base`, `header`, `buttons`).

The layout system: `<main>` is full-width; content is centered via auto horizontal margins
using width variables — set the width with these, don't hard-code:

| variable          | value         | used for                                  |
|-------------------|---------------|-------------------------------------------|
| `--content-width` | `48rem`       | default prose column                      |
| `--content-wide`  | `60rem` (960px) | grids, tables, profile, nav — matches the design's container |
| `--content-full`  | `100%`        | full-bleed                                |

`main > section > *` centers each direct child at `--content-width`. Components/blocks that
need the wide column set `max-width: var(--content-wide)` on `:host` (or add the
`.content-wide` utility class).

The **header** is solid; the **mobile nav** is a CSS-only checkbox hamburger
(`#nav-toggle`) whose dropdown is a translucent, backdrop-blurred panel that slides in.
There is no JavaScript for navigation.

### Components (`src/_includes/components/`)

Reusable UI, each with `<style webc:scoped>`. Naming:

- **`site-*`** — normal components: `site-grid`, `site-info-card`, `site-research-area`,
  `site-person-card`, `site-sponsor-card`, `site-course-card`, `site-contact-card`,
  `site-qa-card`, `site-timeline`, `site-cta`, `site-pub-filter`, `site-publication-list`.
- **tag overrides** — `button.webc` and `footer.webc` redefine the native `<button>` and
  `<footer>` tags (via `<tag webc:root>`), so every such element is themed automatically.

Conventions (please follow):

- **Prefer semantic selectors over classes** (`header nav ul a`, `aria-current`), not
  `.nav`-style classes. Where a class is unavoidable, give it a **descriptive/purpose**
  name (e.g. `.cta`), not a presentational one (`.btn-primary`).
- **Scoped CSS lives with its component.** Theme/global CSS lives in the layout.
- **Content stays organized by page** — pages hold their sections/content and compose
  components; don't hoist a page's content into components.
- Call-to-action links use `<site-cta href="…">`; real buttons are `<button>` (themed by
  `button.webc`).

### Data (`src/_data/`)

Pages render from JSON data with `webc:for`:

- `people.json` — array of `{ group, members: [{ name, role, topic?, affiliation?, photo?, initials?, links? }] }`.
  A member is shown with a photo (`photo`) or initials placeholder (`initials`); the photo
  links to the member's `Homepage` link if present.
- `tools.json` — `{ name, href, description, category }` rows for the Tools table.
- `sponsors.json` — `{ group, sponsors: [{ name, href, logo }] }` (logos in `upload/images/sponsors/`).
- `courses.json` — `{ university, courses: [{ title, meta, description }] }` (used by the
  Teaching page **and** the profile's teaching list).
- `profile.json` — the PI profile: `questions`, `education`, `honors`, `selectedPublications`.
- `publications.json` — **the full publication list** (see below).

### Publications (data-driven + client-side filtering)

This is the one page that renders on the **client**:

- `src/_data/publications.json` is an array of entries:
  `{ year, type: "journal"|"conference", venue, topic, content, pdf }` where `content` is
  pre-formatted HTML (authors with `<strong>Weiyi Shang</strong>`, title, `<em>venue</em>`).
  It is the complete list ported from the `main` branch's `publications.html` (its
  `data-venue`/`data-topic` are hand-curated and authoritative).
- `site-publication-list.webc` embeds that array into the page's JS bundle as
  `window.__PUBS__`, then a client script groups it by year (desc) and journal/conference,
  renders the entries (with `data-*` attributes), populates the year/venue dropdowns, and
  runs the search + topic/type/year/venue filtering. `site-pub-filter.webc` is the filter
  UI; the two are wired together by element IDs.
- PDFs live in `pubs/` and are linked as `/pubs/<file>`. To add/replace publications, edit
  `publications.json` and add the PDF to `pubs/`.

---

## Common tasks

- **Add a page:** create `src/<name>.webc` with front matter `title` + `description`, then a
  `<section id="<name>">` with content; add a nav link in `base.webc`. **Do not** add a
  `permalink` to a `.webc` page's front matter — it silently breaks the build; rely on
  filename routing.
- **Add a person:** add an entry to the right group in `people.json`. Drop their photo in
  `upload/images/` (referenced by filename), or give `initials` for a placeholder.
- **Edit publications:** edit `src/_data/publications.json` (and add the PDF to `pubs/`).
- **Add a component:** create `src/_includes/components/site-foo.webc` with a `:host`
  block and `<style webc:scoped>`; use it as `<site-foo>`.
- **Change the theme:** edit the `--color-*` / font / `--content-*` tokens in `base.webc`.

---

## WebC gotchas (important)

These are non-obvious and have bitten us:

- **No `permalink` in a page's front matter** — the page silently fails to build. Use
  filename-based routing.
- **Don't use `webc:scoped` on *pages*.** WebC emits a page's own rules as `.scope #section`
  but puts `.scope` on the section element itself (no `.scope` ancestor), so the rules never
  match and the page renders unstyled. Pages use a plain `<style>` scoped naturally by their
  unique section id (`#hero`, `#research`, …). CSS is bundled per-page, so this doesn't leak
  across pages — but a generic selector (`h3`, `table`) **can** leak into components on the
  same page, so target with the section id / child combinators (e.g. `#teaching > section > h3`).
  Components keep `webc:scoped` (they work, via `:host`).
- **Scoped styles reach slotted content** (the scope class is on the host, selectors are
  descendants). So a component's bare `h4 {}` will also style a slotted `<h4>` — target the
  component's own element specifically (e.g. `article > h4:first-child`).
- **`:host { display: block }`** is needed so a component centers via `margin-inline: auto`.
- **Access global data as `$data.xxx`** inside components (the bare name isn't in scope);
  `webc:setup` runs before props bind, so compute prop-derived values in the page and pass
  them in.
- **Tag overrides:** name a component after an HTML tag (`button.webc`) with `<tag webc:root>`;
  host attributes (including `id`) are merged and there's no recursion.
- **Don't use `--incremental=false`** — it corrupts a `.cache` state that then silently skips
  templates. If a build goes weird, `rm -rf _site .cache`.
- **Embedding HTML data in a `<script>` via `@html`:** WebC entity-encodes `<`, `>`, `&`. To
  ship raw HTML (as the publications data island does), escape them as `\uXXXX` so no literal
  `<>&` remain for WebC to touch; the browser decodes them back.

---

## Deployment

Push to `main` → GitHub Actions builds with Node + `npm ci` + `npm run build` and deploys
`_site/` to GitHub Pages.

> The publication PDFs in `pubs/` are large (~200 MB); a few exceed GitHub's 50 MB
> *recommended* file size (warnings only, not failures). If repo size becomes a concern,
> move `pubs/` to Git LFS.
