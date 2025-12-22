# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class PdfRenderer
      CSS_DPI = 96.0
      PDF_DPI = 72.0

      PAGE_WIDTH_PX  = 800
      PAGE_HEIGHT_PX = 1000

      def self.render(box_tree, output_path)
        doc = HexaPDF::Document.new

        page_width_pt  = px_to_pt(PAGE_WIDTH_PX)
        page_height_pt = px_to_pt(PAGE_HEIGHT_PX)

        page = doc.pages.add([0, 0, page_width_pt, page_height_pt])
        canvas = page.canvas

        render_box(canvas, box_tree, page_height_pt)

        doc.write(output_path)
      end

      # ------------------------------------------------------------

      def self.render_box(canvas, box, page_height_pt)
        draw_borders(canvas, box, page_height_pt)

        if box.is_a?(SilkLayout::Layout::TextBox)
          render_text(canvas, box, page_height_pt)
        end

        box.children.each do |child|
          render_box(canvas, child, page_height_pt)
        end
      end

      # ------------------------------------------------------------

      def self.render_text(canvas, box, page_height_pt)
        font_size_px = box.font_size || 16
        font_name    = box.font_family || "Helvetica"

        font_size_pt = px_to_pt(font_size_px)

        canvas.font(font_name, size: font_size_pt)

        x_pt = px_to_pt(box.x)
        y_pt = page_height_pt - px_to_pt(box.y) - font_size_pt

        canvas.text(box.text, at: [x_pt, y_pt])
      end

      # ------------------------------------------------------------

      def self.draw_borders(canvas, box, page_height_pt)
        x_pt = px_to_pt(box.border_box_x)
        y_pt = page_height_pt - px_to_pt(box.border_box_y + box.border_box_height)
        w_pt = px_to_pt(box.border_box_width)
        h_pt = px_to_pt(box.border_box_height)

        draw_border(canvas, x_pt, y_pt + h_pt, w_pt, box.border[:top],    box.border_color[:top])
        draw_border(canvas, x_pt, y_pt,         w_pt, box.border[:bottom], box.border_color[:bottom])
        draw_border(canvas, x_pt, y_pt,          box.border[:left],  h_pt, box.border_color[:left])
        draw_border(canvas, x_pt + w_pt - px_to_pt(box.border[:right]),
                    y_pt,
                    box.border[:right],
                    h_pt,
                    box.border_color[:right])
      end

      def self.draw_border(canvas, x, y, w, h, color)
        return if w <= 0 || h <= 0

        set_color(canvas, color)
        canvas.rectangle(x, y, px_to_pt(w), px_to_pt(h)).fill
      end

      # ------------------------------------------------------------

      def self.set_color(canvas, color)
        case color
        when :red   then canvas.fill_color(1, 0, 0)
        when :green then canvas.fill_color(0, 1, 0)
        when :blue  then canvas.fill_color(0, 0, 1)
        else
          canvas.fill_color(0, 0, 0)
        end
      end

      # ------------------------------------------------------------

      def self.px_to_pt(px)
        px * PDF_DPI / CSS_DPI
      end

      private_class_method :render_box
    end
  end
end

