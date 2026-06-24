# TODO

### Blogs

- [ ] Template for blog posts
  - [ ] List of posts on the side
  - [ ] Most recent post visible on index(?)

### Content & metadata

- [ ] Add `content/blog/_index.md` so the blog section has its own title and description (the list page currently falls back to the site description)
- [ ] Give each blog post a `description` in front matter (the meta and social-share text otherwise fall back to a trimmed auto-summary)


### Build & tooling

- [ ] Resolve the Sass mismatch: CI and `setup.sh` install Dart Sass, but the templates compile SCSS with `toCSS` (the embedded LibSass), so Dart Sass is never actually used. Either switch the pipeline to Dart Sass (`css.Sass` with `transpiler: "dartsass"` - LibSass is deprecated upstream) or drop the unused install. Either way, align the version between `setup.sh` (1.83.4) and CI (1.89.0)

### SEO & accessibility

- [ ] Add a custom `404.html` (GitHub Pages serves it on not-found)
- [ ] Add a skip-to-content link, and give gallery images plain-text `alt` (the current `alt` embeds `<b>`/`<br>` markup)
