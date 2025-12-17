# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class PdfRenderer
      PAGE_WIDTH = 800
      PAGE_HEIGHT = 1000

      def self.render(box_tree, output_path)
        doc = HexaPDF::Document.new
        page = doc.pages.add([0, 0, PAGE_WIDTH, PAGE_HEIGHT])
        canvas = page.canvas
        render_box(canvas, box_tree)

        doc.write(output_path)
      end
      
      def self.render_box(canvas, box)
        # Draw border box
        bx = box.border_box_x
        by = PAGE_HEIGHT - box.border_box_y - box.border_box_height

        canvas
          .stroke_color(0, 0, 0)
          .rectangle(bx, by, box.border_box_width, box.border_box_height)
          .stroke

        # Draw text (CONTENT box!)
        if box.is_a?(SilkLayout::Layout::TextBox)
          cx = box.content_box_x
          cy = PAGE_HEIGHT - box.content_box_y - box.content_box_height
          canvas.font("Helvetica", size: 12)
          canvas.text(
            box.text,
            at: [cx, cy + box.content_box_height - 12]
         )
        end

        box.children.each { |child| render_box(canvas, child) }
      end

      private_class_method :render_box
    end
  end
end
