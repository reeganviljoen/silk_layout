# Contributing

Thanks for helping improve SilkLayout.

SilkLayout is still pre-1.0, so the best contributions are focused, test-backed,
and explicit about the rendering behavior they change.

## Development Setup

```sh
bundle install
```

Run the full gate:

```sh
bundle exec rake
```

Run lint only:

```sh
bundle exec standardrb
```

Run tests only:

```sh
bundle exec rake test
```

Run one test file:

```sh
bundle exec ruby -Ilib:test test/layout/flex_layout_test.rb
```

Run one test method:

```sh
bundle exec ruby -Ilib:test test/layout/flex_layout_test.rb -n /justify_content/
```

Run the package smoke check:

```sh
bundle exec rake package:smoke
```

## Visual Tests

Visual scenarios live in `test/visual/<scenario>/` and include an `input.html`
file. The visual suite renders both Chromium and SilkLayout output, converts the
PDFs to PNGs, and compares pixels.

Visual tests require:

- Chromium or Chrome for `ferrum`
- Poppler or ImageMagick for PDF-to-PNG conversion

Artifacts are written to `tmp/visual/` and should not be committed unless they
are intentionally copied into documentation.

Run the full visual suite:

```sh
BROWSER_PATH=/path/to/chrome bundle exec ruby -Ilib:test test/visual_test.rb
```

Run a single visual fixture:

```sh
BROWSER_PATH=/path/to/chrome bundle exec ruby -Ilib:test test/visual_test.rb -n test_visual_flex_row_basic
```

## Pull Requests

Please keep PRs focused. A good rendering PR usually includes:

- a short explanation of the CSS/HTML behavior being added or fixed
- unit tests for layout internals when possible
- visual fixtures for user-visible rendering behavior
- a note about known limitations if the implementation is intentionally partial

## Coding Style

This repository uses StandardRB.

Prefer small, direct Ruby objects over broad abstractions. Match the existing
layout, CSS, and render namespaces when adding files.
