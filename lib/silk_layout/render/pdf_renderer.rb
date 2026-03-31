# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class PdfRenderer
      CSS_DPI = 96.0
      PDF_DPI = 72.0

      PAGE_WIDTH_PX = 800
      PAGE_HEIGHT_PX = 1000

      def self.render(box_tree, output_path)
        doc = HexaPDF::Document.new

        page_width_pt = px_to_pt(PAGE_WIDTH_PX)
        page_height_pt = px_to_pt(PAGE_HEIGHT_PX)

        page = doc.pages.add([0, 0, page_width_pt, page_height_pt])
        Painter.paint(page.canvas, box_tree, page_height_pt)

        doc.write(output_path)
      end

      def self.px_to_pt(px)
        px * PDF_DPI / CSS_DPI
      end
    end
  end
end
