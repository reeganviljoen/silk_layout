---
layout: default
title: 0.1 Release
---

<section class="hero" id="goal">
  <p class="eyebrow">Ruby-native HTML/CSS to PDF</p>
  <h1>SilkLayout is building a full Ruby layout engine.</h1>
  <p class="lede">
    The goal is to render real HTML and CSS documents to PDF without shelling out to a browser engine.
    The 0.1 release is the first practical milestone: block layout, inline text, box model styling,
    basic flexbox, and PDF painting for text, borders, and backgrounds.
  </p>
  <div class="notice">
    SilkLayout is not 1.0 yet. The current work is aimed at a useful 0.1 release and a clear path toward browser-like document rendering over time.
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
      <p>Block stacking, inline text wrapping, width and height handling, box model spacing, and practical flex rows and columns.</p>
    </article>
    <article class="panel">
      <h3>PDF Rendering</h3>
      <p>Text, borders, per-side border colors, and simple background colors are painted into generated PDFs.</p>
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
  <h2>Supported So Far</h2>
  <ul class="status-list">
    <li><strong>HTML document parsing</strong><span>Elements, text nodes, stylesheets, and base URLs.</span></li>
    <li><strong>CSS cascade basics</strong><span>Selectors, specificity, inheritance, inline styles, and important declarations.</span></li>
    <li><strong>Block layout</strong><span>Stacking, explicit widths, heights, margins, padding, and borders.</span></li>
    <li><strong>Inline layout</strong><span>Text measurement, line boxes, whitespace normalization, and wrapping.</span></li>
    <li><strong>Flex layout</strong><span>Rows, columns, reverse directions, wrapping, gaps, grow, shrink, basis, justify, and align basics.</span></li>
    <li><strong>PDF painting</strong><span>Text, borders, border colors, and simple background colors.</span></li>
  </ul>
</section>
<section id="before-1">
  <h2>Before 1.0</h2>
  <ul class="roadmap-list">
    <li><strong>Images</strong><span>Load and size local and remote images in PDF output.</span></li>
    <li><strong>Percent and calc sizing</strong><span>Resolve relative sizes against containing blocks.</span></li>
    <li><strong>Min and max constraints</strong><span>Support min/max width and height in block and flex layout.</span></li>
    <li><strong>Pagination</strong><span>Page breaks, repeated headers/footers, and overflow across pages.</span></li>
    <li><strong>CSS Grid</strong><span>Track sizing, placement, and grid gaps after flex stabilizes.</span></li>
    <li><strong>Positioning</strong><span>Relative, absolute, fixed, and sticky positioning.</span></li>
    <li><strong>Tables and lists</strong><span>Table layout plus marker rendering for ordered and unordered lists.</span></li>
    <li><strong>Richer painting</strong><span>Border radius, shadows, background images, gradients, and more color formats.</span></li>
  </ul>
</section>
