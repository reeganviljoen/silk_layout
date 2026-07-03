---
layout: default
title: 0.2 Release
---

<section class="hero" id="goal">
  <p class="eyebrow">Ruby-native HTML/CSS to PDF</p>
  <h1>SilkLayout is building a full Ruby layout engine.</h1>
  <p class="lede">
    The goal is to render real HTML and CSS documents to PDF without shelling out to a browser engine.
    The 0.2 release track builds on the first practical milestone with a clearer support matrix,
    packaging smoke checks, and targeted work on images, CSS values, color parsing, and print sizing.
  </p>
  <div class="notice">
    SilkLayout is not 1.0 yet. Current, partial, and unsupported features are documented explicitly so 0.2 can ship without implying browser-complete CSS support.
  </div>
</section>

<section id="status">
  <h2>Current Status</h2>
  <div class="grid">
    <article class="panel">
      <h3>Parser and Cascade</h3>
      <p>HTML parsing, inline styles, linked stylesheets, selector matching, specificity, inheritance, and important declarations.</p>
    </article>
    <article class="panel">
      <h3>Layout</h3>
      <p>Block stacking, inline text wrapping, width and height handling, box model spacing, and practical but partial flex rows and columns.</p>
    </article>
    <article class="panel">
      <h3>PDF Rendering</h3>
      <p>Text, borders, per-side border colors, and simple background colors are current. The 0.2 track adds package smoke coverage for installed-gem rendering.</p>
    </article>
  </div>
</section>

<section id="examples">
  <h2>Preview Gallery</h2>
  <p>
    Each example compares a Chromium reference PDF render with SilkLayout's Ruby engine output.
    These screenshots come from the visual regression suite.
  </p>

  <div class="examples">
    <article class="example">
      <div class="example-header">
        <div>
          <h3>Flex Row With Backgrounds</h3>
          <p>Exercises flex row positioning, gap, alignment, borders, text, and background color painting.</p>
        </div>
        <code>display:flex</code>
      </div>
      <div class="comparison">
        <div class="shot">
          <b>Chromium reference</b>
          <img src="{{ '/assets/screenshots/flex_row_basic_browser.png' | relative_url }}" alt="Chromium render of a flex row">
        </div>
        <div class="shot">
          <b>SilkLayout output</b>
          <img src="{{ '/assets/screenshots/flex_row_basic_silk.png' | relative_url }}" alt="SilkLayout render of a flex row">
        </div>
      </div>
    </article>

    <article class="example">
      <div class="example-header">
        <div>
          <h3>Border Color and Padding</h3>
          <p>Exercises solid borders, padding, text placement, and box dimensions.</p>
        </div>
        <code>border + padding</code>
      </div>
      <div class="comparison">
        <div class="shot">
          <b>Chromium reference</b>
          <img src="{{ '/assets/screenshots/border_color_padding_browser.png' | relative_url }}" alt="Chromium render of border and padding">
        </div>
        <div class="shot">
          <b>SilkLayout output</b>
          <img src="{{ '/assets/screenshots/border_color_padding_silk.png' | relative_url }}" alt="SilkLayout render of border and padding">
        </div>
      </div>
    </article>

    <article class="example">
      <div class="example-header">
        <div>
          <h3>Text Wrapping</h3>
          <p>Exercises inline text measurement and wrapping inside a constrained block.</p>
        </div>
        <code>inline layout</code>
      </div>
      <div class="comparison">
        <div class="shot">
          <b>Chromium reference</b>
          <img src="{{ '/assets/screenshots/text_wrapping_browser.png' | relative_url }}" alt="Chromium render of wrapped text">
        </div>
        <div class="shot">
          <b>SilkLayout output</b>
          <img src="{{ '/assets/screenshots/text_wrapping_silk.png' | relative_url }}" alt="SilkLayout render of wrapped text">
        </div>
      </div>
    </article>

    <article class="example">
      <div class="example-header">
        <div>
          <h3>Selector Combinators</h3>
          <p>Exercises selector matching and cascade behavior across nested elements.</p>
        </div>
        <code>CSS cascade</code>
      </div>
      <div class="comparison">
        <div class="shot">
          <b>Chromium reference</b>
          <img src="{{ '/assets/screenshots/selector_combinators_browser.png' | relative_url }}" alt="Chromium render of selector combinator styling">
        </div>
        <div class="shot">
          <b>SilkLayout output</b>
          <img src="{{ '/assets/screenshots/selector_combinators_silk.png' | relative_url }}" alt="SilkLayout render of selector combinator styling">
        </div>
      </div>
    </article>
  </div>
</section>

<section id="supported">
  <h2>0.2 Support Matrix</h2>
  <ul class="status-list">
    <li><strong>Current: HTML document parsing</strong><span>Elements, text nodes, attributes, inline styles, style blocks, linked stylesheets, and base URLs.</span></li>
    <li><strong>Current: CSS cascade basics</strong><span>Selectors, specificity, inheritance, inline styles, important declarations, and fail-closed handling for unsupported selectors.</span></li>
    <li><strong>Current: Block and inline layout</strong><span>Block stacking, text measurement, line boxes, whitespace normalization, wrapping, margins, padding, borders, width, and height.</span></li>
    <li><strong>Current: Visual regression harness</strong><span>Chromium reference PDFs, SilkLayout PDFs, PNG conversion, and pixel comparison with artifacts in <code>tmp/visual/</code>.</span></li>
    <li><strong>Partial: Flex layout</strong><span>Rows, columns, reverse directions, wrapping, gaps, grow, shrink, basis, justify, and align basics are covered; complete flexbox parity is not.</span></li>
    <li><strong>Partial / 0.2 target: CSS values and colors</strong><span>Pixel lengths are current. The 0.2 track covers common percent and <code>calc()</code> lengths plus named, hex, RGB, HSL, alpha, and transparent colors.</span></li>
    <li><strong>Partial / 0.2 target: Images</strong><span>Local image loading, intrinsic sizing, and PDF smoke coverage are planned. Remote images, SVG, animated formats, object fitting, and object positioning remain unsupported.</span></li>
    <li><strong>Partial / 0.2 target: Print sizing</strong><span>Explicit page options are current. The 0.2 track covers basic <code>@page size</code> handling, not full paged-media behavior.</span></li>
    <li><strong>Unsupported: Pagination and fragmentation</strong><span>Page breaks, repeated headers and footers, multi-page overflow, widows, orphans, and fragmentation controls are not implemented yet.</span></li>
    <li><strong>Unsupported: Advanced layout</strong><span>CSS Grid, positioning, floats, tables, and list markers are not implemented yet.</span></li>
    <li><strong>Unsupported: Advanced painting</strong><span>Border radius, shadows, gradients, background images, filters, transforms, and blend modes are not implemented yet.</span></li>
  </ul>
</section>
<section id="before-1">
  <h2>Before 1.0</h2>
  <ul class="roadmap-list">
    <li><strong>Remote images and richer media</strong><span>Extend the 0.2 local-image work to remote assets, SVG, and more replaced-element behavior.</span></li>
    <li><strong>Complete CSS sizing</strong><span>Broaden percent and calc support into the full sizing model and more containing-block cases.</span></li>
    <li><strong>Min and max constraints</strong><span>Support min/max width and height in block and flex layout.</span></li>
    <li><strong>Pagination</strong><span>Page breaks, repeated headers/footers, and overflow across pages.</span></li>
    <li><strong>CSS Grid</strong><span>Track sizing, placement, and grid gaps after flex stabilizes.</span></li>
    <li><strong>Positioning</strong><span>Relative, absolute, fixed, and sticky positioning.</span></li>
    <li><strong>Tables and lists</strong><span>Table layout plus marker rendering for ordered and unordered lists.</span></li>
    <li><strong>Richer painting</strong><span>Border radius, shadows, background images, gradients, and more color formats.</span></li>
  </ul>
</section>
