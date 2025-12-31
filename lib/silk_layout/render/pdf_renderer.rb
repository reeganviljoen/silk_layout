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
        font_name = box.font_family || "Helvetica"

        font_size_pt = px_to_pt(font_size_px)

        canvas.font(font_name, size: font_size_pt)

        x_pt = px_to_pt(box.x)
        y_pt = page_height_pt - px_to_pt(box.y) - font_size_pt

        canvas.text(box.text, at: [x_pt, y_pt])
      end

      # ------------------------------------------------------------

      def self.draw_borders(canvas, box, page_height_pt)
        return if box.is_a?(SilkLayout::Layout::AnonymousBlockBox)
        return unless box.has_border

        x = px_to_pt(box.border_box_x)
        y = page_height_pt - px_to_pt(box.border_box_y + box.border_box_height)
        w = px_to_pt(box.border_box_width)
        h = px_to_pt(box.border_box_height)

        # --- Top border
        if box.border[:top] > 0
          canvas = set_color(canvas, box.border_color[:top])
          canvas.rectangle(
            x,
            y + h - px_to_pt(box.border[:top]),
            w,
            px_to_pt(box.border[:top])
          ).fill
        end

        # --- Bottom border
        if box.border[:bottom] > 0
          canvas = set_color(canvas, box.border_color[:bottom])
          canvas.rectangle(
            x,
            y,
            w,
            px_to_pt(box.border[:bottom])
          ).fill
        end

        # --- Left border
        if box.border[:left] > 0
          canvas = set_color(canvas, box.border_color[:left])
          canvas.rectangle(
            x,
            y,
            px_to_pt(box.border[:left]),
            h
          ).fill
        end

        # --- Right border
        if box.border[:right] > 0
          canvas = set_color(canvas, box.border_color[:right])
          canvas.rectangle(
            x + w - px_to_pt(box.border[:right]),
            y,
            px_to_pt(box.border[:right]),
            h
          ).fill
        end
      end

      # ------------------------------------------------------------

      def self.set_color(canvas, color)
        return unless color

        case color
        when :red then canvas.fill_color(1, 0, 0)
        when :green then canvas.fill_color(0, 1, 0)
        when :blue then canvas.fill_color(0, 0, 1)
        when :black then canvas.fill_color(0, 0, 0)
        when :white then canvas.fill_color(1, 1, 1)
        end
        canvas
      end

      # ------------------------------------------------------------

      def self.px_to_pt(px)
        px * PDF_DPI / CSS_DPI
      end

      private_class_method :render_box
    end
  end
end
