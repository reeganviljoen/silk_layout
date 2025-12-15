# frozen_string_literal: true

module SilkLayout
  class Document
    attr_reader :html, :stylesheets

    def initialize(html:, stylesheets: [])
      @html = html
      @stylesheets = stylesheets
    end

    def layout
      dom = HTML::Parser.parse(html)
      rules = CSS::Parser.parse_all(stylesheets)
      CSS::Cascade.apply(dom, rules)
      Layout::Paginator.new(dom).pages
    end

    def to_pdf(io)
      pages = layout
      renderer = Render::PDF.new(io)
      pages.each { |page| renderer.render(page) }
      renderer.finish
    end
  end
end
