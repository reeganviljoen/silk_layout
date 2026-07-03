# frozen_string_literal: true

require "active_support/all"

module SilkLayout
  autoload :VERSION, "silk_layout/version"

  module HTML
    autoload :Parser, "silk_layout/html/parser"
    autoload :Node, "silk_layout/html/node"
  end

  module Resource
    autoload :Image, "silk_layout/resource/image"
  end

  module CSS
    autoload :Parser, "silk_layout/css/parser"
    autoload :Cascade, "silk_layout/css/cascade"
    autoload :ComputedStyle, "silk_layout/css/computed_style"
    autoload :Rule, "silk_layout/css/rule"
    autoload :Declaration, "silk_layout/css/rule"
    autoload :Selector, "silk_layout/css/selector"
    autoload :Properties, "silk_layout/css/properties"
    autoload :Values, "silk_layout/css/values"
    autoload :Color, "silk_layout/css/color"
    autoload :PageRule, "silk_layout/css/page_rule"
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

  def self.render_document(
    html_document,
    out,
    url: nil,
    viewport_width: nil,
    page_size: nil,
    page_width: nil,
    page_height: nil
  )
    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html_document, url: url)
    stylesheet = SilkLayout::CSS::Parser.parse_stylesheets(stylesheets, media: :print)
    css_page_size = SilkLayout::CSS::PageRule.resolve_page_size(stylesheet.page_rules)
    resolved_page_size = resolve_page_size(page_size || css_page_size, page_width, page_height)

    box_tree = SilkLayout::Layout::Engine.layout(
      dom,
      stylesheet.rules,
      viewport_width: viewport_width,
      page_size: resolved_page_size
    )

    SilkLayout::Render::PdfRenderer.render(
      box_tree,
      out,
      page_size: resolved_page_size
    )
  end

  def self.resolve_page_size(page_size, page_width, page_height)
    return page_size unless page_width || page_height

    width, height = page_size_dimensions(page_size)
    {
      width: page_width || width,
      height: page_height || height
    }
  end
  private_class_method :resolve_page_size

  def self.page_size_dimensions(page_size)
    case page_size
    when Array
      page_size
    when Hash
      [page_size[:width] || page_size["width"], page_size[:height] || page_size["height"]]
    else
      [nil, nil]
    end
  end
  private_class_method :page_size_dimensions
end
