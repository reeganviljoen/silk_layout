# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class PdfRenderer
      CSS_DPI = 96.0
      PDF_DPI = 72.0

      DEFAULT_PAGE_WIDTH = 800
      DEFAULT_PAGE_HEIGHT = 1000

      def self.render(box_tree, output_path, page_size: nil, page_width: nil, page_height: nil)
        doc = HexaPDF::Document.new

        resolved_page_width, resolved_page_height = page_dimensions(
          page_size: page_size,
          page_width: page_width,
          page_height: page_height
        )

        page_width_pt = px_to_pt(resolved_page_width)
        page_height_pt = px_to_pt(resolved_page_height)

        page = doc.pages.add([0, 0, page_width_pt, page_height_pt])
        Painter.paint(page.canvas, box_tree, page_height_pt)

        doc.write(output_path)
      end

      def self.px_to_pt(px)
        px * PDF_DPI / CSS_DPI
      end

      def self.page_dimensions(page_size:, page_width:, page_height:)
        width, height = page_size ? normalize_page_size(page_size) : [DEFAULT_PAGE_WIDTH, DEFAULT_PAGE_HEIGHT]

        [
          validate_dimension(page_width || width || DEFAULT_PAGE_WIDTH, "page_width"),
          validate_dimension(page_height || height || DEFAULT_PAGE_HEIGHT, "page_height")
        ]
      end

      def self.normalize_page_size(page_size)
        case page_size
        when Array
          raise ArgumentError, "page_size must contain width and height" unless page_size.length == 2

          page_size
        when Hash
          [page_size[:width] || page_size["width"], page_size[:height] || page_size["height"]]
        else
          raise ArgumentError, "page_size must be an Array or Hash"
        end
      end

      def self.validate_dimension(value, name)
        return value if value.is_a?(Numeric) && value.positive?

        raise ArgumentError, "#{name} must be a positive number of CSS pixels"
      end
    end
  end
end
