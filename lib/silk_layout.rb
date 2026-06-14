# frozen_string_literal: true

require "active_support/all"

module SilkLayout
  autoload :VERSION, "silk_layout/version"

  module HTML
    autoload :Parser, "silk_layout/html/parser"
    autoload :Node, "silk_layout/html/node"
  end

  module CSS
    autoload :Parser, "silk_layout/css/parser"
    autoload :Cascade, "silk_layout/css/cascade"
    autoload :ComputedStyle, "silk_layout/css/computed_style"
    autoload :Rule, "silk_layout/css/rule"
    autoload :Declaration, "silk_layout/css/rule"
    autoload :Selector, "silk_layout/css/selector"
    autoload :Properties, "silk_layout/css/properties"
  end

  module Layout
    autoload :Box, "silk_layout/layout/box"
    autoload :BlockBox, "silk_layout/layout/box"
    autoload :FlexBox, "silk_layout/layout/box"
    autoload :InlineBox, "silk_layout/layout/box"
    autoload :AnonymousBlockBox, "silk_layout/layout/box"
    autoload :Inline, "silk_layout/layout/inline"
    autoload :TextBox, "silk_layout/layout/inline"
    autoload :LineBox, "silk_layout/layout/inline"
    autoload :InlineFormatter, "silk_layout/layout/inline_formatter"
    autoload :FormattingBuilder, "silk_layout/layout/formatting_builder"
    autoload :BoxBuilder, "silk_layout/layout/box_builder"
    autoload :Context, "silk_layout/layout/context"
    autoload :BlockLayout, "silk_layout/layout/block_layout"
    autoload :FlexLayout, "silk_layout/layout/flex_layout"
    autoload :Engine, "silk_layout/layout/engine"
    autoload :Root, "silk_layout/layout/root"
  end

  module Render
    autoload :FontLibrary, "silk_layout/render/font_library"
    autoload :Painter, "silk_layout/render/painter"
    autoload :PdfRenderer, "silk_layout/render/pdf_renderer"
  end

  def self.render_document(html_document, out, url: nil)
    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html_document, url: url)
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)
    box_tree = SilkLayout::Layout::Engine.layout(dom, rules)

    SilkLayout::Render::PdfRenderer.render(box_tree, out)
  end
end
