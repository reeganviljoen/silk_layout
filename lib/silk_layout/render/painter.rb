# frozen_string_literal: true

module SilkLayout
  module Render
    class Painter
      def self.paint(canvas, box, page_height_pt)
        paint_box(canvas, box, page_height_pt)
      end

      def self.paint_box(canvas, box, page_height_pt)
        draw_borders(canvas, box, page_height_pt)

        if box.is_a?(SilkLayout::Layout::TextBox)
          paint_text(canvas, box, page_height_pt)
        end

        box.children.each do |child|
          paint_box(canvas, child, page_height_pt)
        end
      end

      def self.paint_text(canvas, box, page_height_pt)
        font_size_px = box.font_size || 16
        font_name = box.font_name || box.font_family || "Helvetica"

        font_size_pt = PdfRenderer.px_to_pt(font_size_px)
        ascent_pt = PdfRenderer.px_to_pt(box.respond_to?(:ascender) ? box.ascender : font_size_px * 0.8)

        canvas.font(font_name, size: font_size_pt)

        canvas = set_color(canvas, color_to_symbol(box.respond_to?(:color) ? box.color : nil) || :black)

        x_pt = PdfRenderer.px_to_pt(box.x)
        y_pt = page_height_pt - PdfRenderer.px_to_pt(box.y) - ascent_pt

        canvas.text(box.text, at: [x_pt, y_pt])
      end

      def self.draw_borders(canvas, box, page_height_pt)
        return if box.is_a?(SilkLayout::Layout::AnonymousBlockBox)
        return unless box.has_border

        x = PdfRenderer.px_to_pt(box.border_box_x)
        y = page_height_pt - PdfRenderer.px_to_pt(box.border_box_y + box.border_box_height)
        w = PdfRenderer.px_to_pt(box.border_box_width)
        h = PdfRenderer.px_to_pt(box.border_box_height)

        top = PdfRenderer.px_to_pt(box.border[:top])
        bottom = PdfRenderer.px_to_pt(box.border[:bottom])
        left = PdfRenderer.px_to_pt(box.border[:left])
        right = PdfRenderer.px_to_pt(box.border[:right])

        colors = [box.border_color[:top], box.border_color[:right], box.border_color[:bottom], box.border_color[:left]]
        if colors.uniq.length <= 1
          if top > 0
            canvas = set_color(canvas, box.border_color[:top])
            canvas.rectangle(x, y + h - top, w, top).fill
          end

          if bottom > 0
            canvas = set_color(canvas, box.border_color[:bottom])
            canvas.rectangle(x, y, w, bottom).fill
          end

          if left > 0
            canvas = set_color(canvas, box.border_color[:left])
            canvas.rectangle(x, y, left, h).fill
          end

          if right > 0
            canvas = set_color(canvas, box.border_color[:right])
            canvas.rectangle(x + w - right, y, right, h).fill
          end

          return
        end

        inner_w = [w - left - right, 0].max
        inner_h = [h - top - bottom, 0].max

        if top > 0 && inner_w > 0
          canvas = set_color(canvas, box.border_color[:top])
          canvas.rectangle(x + left, y + h - top, inner_w, top).fill
        end

        if bottom > 0 && inner_w > 0
          canvas = set_color(canvas, box.border_color[:bottom])
          canvas.rectangle(x + left, y, inner_w, bottom).fill
        end

        if left > 0 && inner_h > 0
          canvas = set_color(canvas, box.border_color[:left])
          canvas.rectangle(x, y + bottom, left, inner_h).fill
        end

        if right > 0 && inner_h > 0
          canvas = set_color(canvas, box.border_color[:right])
          canvas.rectangle(x + w - right, y + bottom, right, inner_h).fill
        end

        draw_corner(
          canvas,
          x,
          y + h - top,
          left,
          top,
          box.border_color[:left],
          box.border_color[:top],
          :top_left
        )

        draw_corner(
          canvas,
          x + w - right,
          y + h - top,
          right,
          top,
          box.border_color[:right],
          box.border_color[:top],
          :top_right
        )

        draw_corner(
          canvas,
          x,
          y,
          left,
          bottom,
          box.border_color[:left],
          box.border_color[:bottom],
          :bottom_left
        )

        draw_corner(
          canvas,
          x + w - right,
          y,
          right,
          bottom,
          box.border_color[:right],
          box.border_color[:bottom],
          :bottom_right
        )
      end

      def self.set_color(canvas, color)
        return canvas unless color

        case color
        when :red then canvas.fill_color(255, 0, 0)
        when :green then canvas.fill_color(0, 255, 0)
        when :blue then canvas.fill_color(0, 0, 255)
        when :black then canvas.fill_color(0, 0, 0)
        end
        canvas
      end

      def self.color_to_symbol(color)
        return nil unless color

        normalized = color.to_s.strip
        return nil if normalized.empty?

        normalized.to_sym
      end

      def self.draw_corner(canvas, x, y, w, h, vertical_color, horizontal_color, kind)
        return if w <= 0 || h <= 0

        if vertical_color == horizontal_color
          canvas = set_color(canvas, vertical_color)
          canvas.rectangle(x, y, w, h).fill
          return
        end

        case kind
        when :top_left
          fill_triangle(canvas, horizontal_color, [x, y + h], [x + w, y + h], [x + w, y])
          fill_triangle(canvas, vertical_color, [x, y + h], [x + w, y], [x, y])
        when :top_right
          fill_triangle(canvas, horizontal_color, [x, y + h], [x + w, y + h], [x, y])
          fill_triangle(canvas, vertical_color, [x + w, y + h], [x + w, y], [x, y])
        when :bottom_left
          fill_triangle(canvas, horizontal_color, [x, y], [x + w, y], [x + w, y + h])
          fill_triangle(canvas, vertical_color, [x, y], [x + w, y + h], [x, y + h])
        when :bottom_right
          fill_triangle(canvas, horizontal_color, [x, y], [x + w, y], [x, y + h])
          fill_triangle(canvas, vertical_color, [x + w, y], [x + w, y + h], [x, y + h])
        end
      end

      def self.fill_triangle(canvas, color, p1, p2, p3)
        canvas = set_color(canvas, color)
        canvas.move_to(*p1)
        canvas.line_to(*p2)
        canvas.line_to(*p3)
        canvas.close_subpath.fill
      end

      private_class_method :paint_box
    end
  end
end
