# Changelog

All notable changes to SilkLayout will be documented here.

This project follows a lightweight changelog format while it is pre-1.0.

## Unreleased

- Add 0.2 release/DX documentation, including a current/partial/unsupported
  support matrix and explicit unit, visual, single-fixture, and package smoke
  commands.
- Add a package smoke Rake task and CI job that builds the gem, installs it into
  a temporary `GEM_HOME`, requires the installed package, and renders a smoke
  PDF.

## 0.2.0

Draft notes for the 0.2 release. Before tagging, verify each runtime bullet
against the merged implementation and move any unfinished item back to
Unreleased or the before-1.0 roadmap.

### Planned runtime scope

- Local raster image loading, intrinsic image sizing, and PDF rendering smoke
  coverage.
- CSS value hardening for common percent and `calc()` length cases.
- Richer color parsing for named colors, hex colors, `rgb()`, `rgba()`,
  `hsl()`, `hsla()`, and `transparent`.
- Basic print CSS page sizing through explicit options and `@page size`.
- Continued cascade, selector, box model, inline layout, flex layout, and visual
  parity hardening.

### Release and DX

- Document the 0.2 support matrix as current, partial, or unsupported rather
  than browser-complete.
- Document unit test, visual regression, single visual fixture, and package smoke
  commands in the README and contribution guide.
- Add `bundle exec rake package:smoke` for a build/install/require/render smoke
  path.
- Add CI coverage for the package smoke path on the release Ruby.

### Known gaps

- Pagination, page-break controls, repeated headers/footers, and multi-page
  fragmentation remain unsupported.
- CSS Grid, positioning, floats, tables, and list markers remain unsupported.
- Border radius, shadows, gradients, background images, filters, transforms, and
  blend modes remain unsupported.
- Remote images, SVG, animated image formats, `object-fit`, and
  `object-position` remain unsupported.

## 0.1.0

- Add public project README, MIT license, contribution guide, security policy,
  and issue templates.
- Prepare repository metadata for public visibility.
- Ruby-native HTML/CSS parsing, layout, and PDF rendering foundation.
- Block and inline layout support.
- Box model support for margins, padding, borders, and backgrounds.
- Basic flex layout support.
- Visual regression tests against Chromium output.
