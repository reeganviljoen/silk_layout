# SilkLayout

SilkLayout is a Ruby-native HTML/CSS layout engine that renders documents to PDF.

The long-term goal is to make PDF generation feel natural inside Ruby apps without
delegating layout to a browser engine. The project is currently on the `0.1`
release track: useful for experimentation, regression testing, and early document
rendering, but not yet 1.0 or browser-spec complete.

## Current Status

SilkLayout currently supports:

- HTML parsing with Nokogiri
- CSS parsing with Crass
- CSS cascade basics, selector matching, specificity, inheritance, inline styles,
  and `!important`
- block layout, inline text layout, line wrapping, and whitespace normalization
- box model spacing: margin, padding, borders, border colors, width, and height
- basic flex layout: rows, columns, reverse directions, wrapping, gaps, grow,
  shrink, basis, justify, and align basics
- PDF rendering with HexaPDF for text, borders, border colors, and simple
  background colors
- visual regression tests against Chromium output

Not yet supported:

- CSS Grid
- percentage and `calc()` sizing
- images
- pagination and page-break controls
- positioning, floats, tables, and list markers
- border radius, shadows, gradients, and background images
- full CSS color syntax such as `rgb()`, `rgba()`, and `hsl()`

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

Run lint:

```sh
bundle exec standardrb
```

Run a single test file:

```sh
bundle exec ruby -Ilib:test test/layout/flex_layout_test.rb
```

Visual regression tests require Chromium or Chrome plus PDF-to-PNG tooling such
as Poppler or ImageMagick. Generated visual artifacts are written to
`tmp/visual/`.

## Releasing

This gem is still `0.1.0.dev`. Before a public 1.0 release, the project should
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
