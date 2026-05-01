# Development

Development notes and references for this project

## Setup

Run `./scripts/setup.sh` to install Hugo extended, Dart Sass, npm dependencies, and pre-commit (Linux only). Binaries land in `~/.local/bin` — make sure that's on your `PATH`.

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

## Changelog

### 2024-12-01

Switched to [Hugo](https://gohugo.io/documentation/)

## Links

Links to useful resources

[CSS Units](https://www.geeksforgeeks.org/css-units-em-rem-px-vh-vw/)

[Hugo Theme Gallery](https://github.com/nicokaiser/hugo-theme-gallery/)
