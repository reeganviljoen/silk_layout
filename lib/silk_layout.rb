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
    autoload :Selector, "silk_layout/css/selector"
    autoload :Properties, "silk_layout/css/properties"
  end

  module Layout
    autoload :Box, "silk_layout/layout/box"
    autoload :Block, "silk_layout/layout/block"
    autoload :BlockBox, "silk_layout/layout/block"
    autoload :InlineBox, "silk_layout/layout/block"
    autoload :AnonymousBlockBox, "silk_layout/layout/block"
    autoload :Inline, "silk_layout/layout/inline"
    autoload :TextBox, "silk_layout/layout/inline"
    autoload :LineBox, "silk_layout/layout/inline"
    autoload :BoxBuilder, "silk_layout/layout/box_builder"
    autoload :Context, "silk_layout/layout/context"
    autoload :BlockLayout, "silk_layout/layout/block_layout"
    autoload :Engine, "silk_layout/layout/engine"
    autoload :Root, "silk_layout/layout/root"
  end

  module Render
    autoload :PdfRenderer, "silk_layout/render/pdf_renderer"
  end

  def self.render(html, css, out)
    dom = SilkLayout::HTML::Parser.parse(html)
    rules = SilkLayout::CSS::Parser.parse_all([css])
    box_tree = SilkLayout::Layout::Engine.layout(dom, rules)

    SilkLayout::Render::PdfRenderer.render(box_tree, out)
  end
end
