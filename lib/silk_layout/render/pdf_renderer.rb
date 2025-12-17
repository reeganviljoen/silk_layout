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
        # Render children first (debug clarity)
        box.children.each do |child|
          render_box(canvas, child)
        end

        # Draw this box
        x = box.x
        y = PAGE_HEIGHT - box.y - box.height

        canvas
          .stroke_color(0, 0, 0)
          .rectangle(x, y, box.width, box.height)
          .stroke

        if box.respond_to?(:text) && box.text
          font_size = 12
          canvas.font("Helvetica", size: font_size)
          canvas.text(
            box.text,
            at: [box.x, PAGE_HEIGHT - box.y - font_size],
          )
        end
      end

      private_class_method :render_box

      private_class_method :render_box
    end
  end
end
