# mona.cool

Source for [mona.cool](https://mona.cool) - my personal corner of the web.

Built with [Hugo](https://gohugo.io/). Layouts are hand-rolled (no third-party
theme); the gallery is adapted from
[hugo-theme-gallery](https://github.com/nicokaiser/hugo-theme-gallery/).

## Stack

- **Hugo Extended** - static site generator. Extended is required because the
  styles are written in SCSS.
- **SCSS** compiled through Hugo Pipes (minified and fingerprinted at build time).
- **Node.js** - the gallery bundles a few npm packages (PhotoSwipe lightbox,
  justified-layout, lazysizes) via Hugo's `js.Build`, so a build needs
  `node_modules` present.
- **GitHub Actions -> GitHub Pages** - every push to `main` builds and deploys.

## Repository layout

```
.
+-- archetypes/      # front-matter template for `hugo new`
+-- assets/          # SCSS + JS processed by Hugo Pipes (css/, js/)
+-- content/
|   +-- blog/        # blog posts (one .md per post)
|   \-- gallery/     # one folder per album (leaf bundle: index.md + images)
+-- i18n/            # UI strings (gallery counts, lightbox labels)
+-- layouts/         # templates: baseof, home, page, blog/, gallery/, _partials/
+-- static/          # files served as-is (favicons, fonts, webring buttons)
+-- hugo.toml        # site config
\-- .github/workflows/hugo.yaml   # build + deploy pipeline
```

`public/` (the built site) and `resources/` (Hugo's asset cache) are generated and
git-ignored

## Quickstart

**Prerequisites:** Hugo Extended, Node.js, and Git.
`./scripts/setup.sh` installs Hugo, Dart Sass, the npm dependencies, and the
pre-commit hooks for you (see [DEV.md](DEV.md) for what it does and how to pin
versions). For other platforms, install [Hugo Extended](https://gohugo.io/installation/)
and [Node.js](https://nodejs.org/), then run `npm ci`.

```sh
git clone https://github.com/CoolCatMona/MonaDotCool.git
cd MonaDotCool
./scripts/setup.sh        # Linux; otherwise install Hugo + Node, then: npm ci
hugo server               # preview at http://localhost:1313
```

## Common commands

| Command                            | What it does                                            |
| ---------------------------------- | ------------------------------------------------------- |
| `hugo server`                      | Live-reloading local preview at `http://localhost:1313` |
| `hugo server -D`                   | Same, but also renders draft content                    |
| `hugo --gc --minify`               | Production build into `public/` (what CI runs)          |
| `hugo new content blog/my-post.md` | Scaffold a new blog post from the archetype             |
| `npm ci`                           | Install/refresh the gallery's JS dependencies           |
| `pre-commit run --all-files`       | Run the formatters and checks across the tree           |

## Writing content

New content starts as a **draft** (`draft: true`, set by the archetype). Drafts are
skipped in production builds, so flip it to `false` when a piece is ready to ship.

### A blog post

```sh
hugo new content blog/my-post.md
```

That gives you a file with `title`, `date`, and `draft: true`. Write below the
front matter in Markdown. Add a `description` to control the meta/social-share text
(otherwise it falls back to the start of the post).

### A gallery album

An album is a folder under `content/gallery/` containing an `index.md` and its
images:

```
content/gallery/my-album/
+-- index.md
+-- photo-1.jpg
\-- photo-2.jpg
```

```yaml
---
title: "My Album"
type: "gallery"
description: "A short blurb shown on the album page"
params:
  album_title: "My Album"
  hover_text: "Tooltip shown on the album card"
resources:
  - src: "photo-1.jpg"
    title: "A caption"
    params:
      cover: true # use this image as the album thumbnail / social-share image
      desc: "Longer description shown in the lightbox"
---
```

Drop the image files in alongside `index.md`. Hugo resizes them (thumbnail +
full size), pulls the dominant color for the background, and the lightbox/justified
layout handle the rest. Per-image `title`, `desc`, and `cover` are optional.

## Publishing

Pushing (or merging) to `main` triggers the
[GitHub Actions workflow](.github/workflows/hugo.yaml), which builds the site with
`hugo --gc --minify` and publishes it to GitHub Pages. The custom domain is set by
the `CNAME` file, so the live site lands at https://mona.cool.

