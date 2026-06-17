# SilkLayout

SilkLayout is a Ruby-native HTML/CSS layout engine that renders documents to PDF.

The long-term goal is to make PDF generation feel natural inside Ruby apps without
delegating layout to a browser engine. The project is currently on the `0.2`
pre-release track: useful for experimentation, regression testing, and early
document rendering, but not yet 1.0 or browser-spec complete.

## Current Status

SilkLayout is pre-1.0, so support is described as current, partial, or
unsupported rather than as a browser compatibility promise.

| Area | 0.2 status | Notes |
| --- | --- | --- |
| HTML parsing | Current | Nokogiri document parsing, text nodes, attributes, inline styles, `<style>` blocks, linked stylesheets, and base URLs. |
| CSS cascade | Current | Crass parsing, selector matching, specificity, inheritance, inline styles, and `!important`; unsupported selectors fail closed. |
| Block and inline layout | Current | Block stacking, inline text measurement, line wrapping, whitespace normalization, margins, padding, borders, width, and height. |
| Flex layout | Partial | Rows, columns, reverse directions, wrapping, gaps, grow, shrink, basis, justify, and align basics; full flexbox parity is still out of scope. |
| CSS values and colors | Partial / 0.2 target | Pixel lengths are current; 0.2 tracks percent and `calc()` lengths for common box values plus named, hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, and `transparent` colors. |
| PDF painting | Partial | Text, borders, border colors, and simple backgrounds are current; 0.2 tracks local raster image painting and print page sizing. |
| Images | Partial / 0.2 target | Local image loading, intrinsic sizing, and PDF smoke coverage are planned for 0.2; remote images, SVG, animated formats, `object-fit`, and `object-position` are unsupported. |
| Visual regression | Current | Chromium reference PDF rendering with PNG comparison; generated artifacts are written to `tmp/visual/`. |
| Pagination and fragmentation | Unsupported | Page breaks, repeated headers/footers, and content overflow across pages are before-1.0 work. |
| Advanced layout | Unsupported | CSS Grid, positioning, floats, tables, and list markers are not implemented yet. |
| Advanced painting | Unsupported | Border radius, shadows, gradients, background images, filters, and transforms are not implemented yet. |

## Installation

Add the gem to your bundle once released:

```ruby
gem "silk_layout"
```

For local development from this repository:

```sh
bundle install
```

## Usage

```ruby
require "silk_layout"

html = <<~HTML
  <!doctype html>
  <html>
    <head>
      <style>
        body { font-family: Helvetica; margin: 0; }
        .row {
          display: flex;
          gap: 16px;
          padding: 16px;
          border: 2px solid black;
        }
        .item {
          width: 80px;
          padding: 8px;
          border: 1px solid blue;
          background: lightblue;
        }
      </style>
    </head>
    <body>
      <div class="row">
        <div class="item">One</div>
        <div class="item">Two</div>
      </div>
    </body>
  </html>
HTML

SilkLayout.render_document(html, "out.pdf")
```

## Documentation

The documentation site lives in [`docs/`](docs/index.md). It includes the project
goal, current support matrix, before-1.0 roadmap, and Chromium-vs-SilkLayout
screenshots from the visual regression suite.

## Development

Run the full local gate:

```sh
bundle exec rake
```

Run tests only:

```sh
bundle exec rake test
```

Run visual regression tests:

```sh
BROWSER_PATH=/path/to/chrome bundle exec ruby -Ilib:test test/visual_test.rb
```

Run lint:

```sh
bundle exec standardrb
```

Run a single test file:

```sh
bundle exec ruby -Ilib:test test/layout/flex_layout_test.rb
```

Run a single visual fixture:

```sh
BROWSER_PATH=/path/to/chrome bundle exec ruby -Ilib:test test/visual_test.rb -n test_visual_flex_row_basic
```

Build and install the gem into a temporary `GEM_HOME`, then require it and render
a smoke PDF from the installed package:

```sh
bundle exec rake package:smoke
```

Visual regression tests require Chromium or Chrome plus PDF-to-PNG tooling such
as Poppler or ImageMagick. Generated visual artifacts are written to
`tmp/visual/`.

## Releasing

SilkLayout releases use the checked-in release script:

```sh
DRY_RUN=1 script/release
script/release
```

The script must be run from a clean, up-to-date `main` branch after the release
PR is merged. It installs dependencies, runs the test/lint/package smoke gate,
publishes the gem through Bundler's release task, and creates a GitHub release
from the matching `CHANGELOG.md` section.

This gem is still pre-1.0. Before a public 1.0 release, the project should
stabilize the supported CSS surface, add pagination, improve visual parity, and
document compatibility promises.

## Contributing

Contributions are welcome while the engine is young. Please read
[`CONTRIBUTING.md`](CONTRIBUTING.md) and open issues or PRs with focused examples
and, where possible, visual regression fixtures.

## Security

Please report security issues privately using the process in
[`SECURITY.md`](SECURITY.md).

## License

SilkLayout is available under the MIT License. See [`LICENSE`](LICENSE).
