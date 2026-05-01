# Development

Development notes and references for this project

## Setup

Run `./scripts/setup.sh` to install Hugo extended, Dart Sass, npm dependencies, and pre-commit (Linux only). Binaries land in `~/.local/bin`; the script appends that directory to your shell rc (`.bashrc` / `.zshrc` / fish `config.fish`) once, so `source` it or open a new shell after the first run.

Override versions if needed: `HUGO_VERSION=0.161.1 DART_SASS_VERSION=1.83.4 ./scripts/setup.sh`.

## Pre-commit

The setup script wires a git hook via `pre-commit install`. On every commit it runs:

- whitespace / EOL / line-ending fixes
- YAML / TOML / JSON syntax checks
- merge-conflict marker check
- large-file check (max 32 MB — bump in [.pre-commit-config.yaml](.pre-commit-config.yaml) if you start adding bigger photos)
- `shellcheck` on shell scripts
- `prettier` on CSS / SCSS / JS / JSON / Markdown

After first install, run `pre-commit run --all-files` once to apply Prettier + EOL fixes across the existing tree (one-time formatting commit).

Skip hooks for a single commit with `git commit --no-verify` — but it's usually faster to fix the issue.

## Running

Start the server with `hugo server` (use `hugo server -D` to preview drafts).

Kill the server with `pkill hugo`.

Build for production with `hugo --gc --minify` — `--gc` cleans stale cache entries from `public/` so drafts and expired files don't linger. CI runs this automatically on push to `main`.

## Adding a font

Self-hosted fonts live in [static/fonts/](static/fonts/) and are referenced by `@font-face` rules in [assets/css/layout.scss](assets/css/layout.scss). Browsers prefer `woff2` (≈30% smaller than `ttf`/`otf`), so convert source files before checking them in.

### Convert OTF/TTF to woff2

Install [fonttools](https://github.com/fonttools/fonttools) once via [uv](https://docs.astral.sh/uv/):

```sh
uv tool install fonttools --with brotli
```

Then convert each weight:

```sh
fonttools ttLib.woff2 compress -o static/fonts/myfont.woff2 path/to/MyFont.otf
```

### Wire it up

Add an `@font-face` block per weight at the top of [assets/css/layout.scss](assets/css/layout.scss):

```scss
@font-face {
  font-family: "MyFont";
  src: url("/fonts/myfont.woff2") format("woff2");
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}
```

Reference the family by name elsewhere (e.g. `font-family: "MyFont", monospace;`).

### Licensing

If the font ships under SIL OFL (or similar), the license must travel with the binaries — copy it into [static/fonts/](static/fonts/) (e.g. as `OFL.txt`) so it's served alongside the font files.

## Changelog

### 2024-12-01

Switched to [Hugo](https://gohugo.io/documentation/)

## Links

Links to useful resources

[CSS Units](https://www.geeksforgeeks.org/css-units-em-rem-px-vh-vw/)

[Hugo Theme Gallery](https://github.com/nicokaiser/hugo-theme-gallery/)
