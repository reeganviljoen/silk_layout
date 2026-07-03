# frozen_string_literal: true

module SilkLayout
  module Layout
    class BlockLayout
      def self.layout(box, context, cursor_y = 0, parent_x = 0, containing_width = nil)
        available_width = containing_width || context.width
        resolve_spacing(box, available_width)

        return FlexLayout.layout(box, context, cursor_y, parent_x, containing_width) if box.is_a?(FlexBox)

        box.x = parent_x + box.margin[:left]
        box.y = cursor_y + box.margin[:top]

        content_x =
          box.x + box.border[:left] + box.padding[:left]

        content_y =
          box.y + box.border[:top] + box.padding[:top]

        content_width = resolved_content_width(box, available_width)

        current_y = content_y
        new_children = []
        inline_buffer = []

        box.children.each do |child|
          if child.is_a?(InlineBox)
            inline_buffer << child
            next
          end

          if inline_buffer.any?
            lines = InlineFormatter.layout(inline_buffer, content_width, content_x, current_y)
            lines.each do |line|
              line.x = content_x
              line.y = current_y
              current_y += line.height
              new_children << line
            end
            inline_buffer.clear
          end

          layout(child, context, current_y, content_x, content_width)

          current_y +=
            child.height +
            child.margin[:top] +
            child.margin[:bottom]

          new_children << child
        end

        if inline_buffer.any?
          lines = InlineFormatter.layout(inline_buffer, content_width, content_x, current_y)
          lines.each do |line|
            line.x = content_x
            line.y = current_y
            current_y += line.height
            new_children << line
          end
        end

        box.children = new_children

        content_height = current_y - content_y
        if box.explicit_height
          content_height = [content_height, content_height_from_css_height(box, declared_height(box))].max
        end

        max_child_width =
          box.children.map(&:width).max || 0

        content_width = max_child_width if !box.explicit_width && content_width == 0

        box.width =
          content_width +
          box.padding[:left] + box.padding[:right] +
          box.border[:left] + box.border[:right]

        box.height =
          content_height +
          box.padding[:top] + box.padding[:bottom] +
          box.border[:top] + box.border[:bottom]
      end

      def self.resolve_spacing(box, available_width)
        box.margin = resolved_edges(box, "margin", available_width, box.margin)
        box.padding = resolved_edges(box, "padding", available_width, box.padding)
      end

      def self.resolved_edges(box, property, available_width, fallback)
        style = box.node&.computed_style
        values = CSS::Values.expanded_edges(style&.[](property))

        {
          top: resolved_edge(style, property, :top, values, available_width, fallback[:top]),
          right: resolved_edge(style, property, :right, values, available_width, fallback[:right]),
          bottom: resolved_edge(style, property, :bottom, values, available_width, fallback[:bottom]),
          left: resolved_edge(style, property, :left, values, available_width, fallback[:left])
        }
      end

      def self.resolved_edge(style, property, side, values, available_width, fallback)
        raw = style&.[]("#{property}-#{side}") || values[side]
        return fallback unless raw

        CSS::Values.resolve_length(raw, reference: available_width, default: fallback)
      end

      def self.resolved_content_width(box, available_width)
        content_width =
          if box.explicit_width
            content_width_from_css_width(box, declared_width(box, available_width))
          else
            auto_content_width(box, available_width)
          end

        [content_width, 0].max
      end

      def self.declared_width(box, available_width)
        raw = style_value(box, "width")
        width =
          if raw && raw != "auto" && !preserve_assigned_width?(box, raw, available_width)
            CSS::Values.resolve_length(raw, reference: available_width, default: box.width)
          else
            box.width
          end

        constrain_css_width(box, width, available_width)
      end

      def self.auto_content_width(box, available_width)
        content_width =
          available_width -
          box.margin[:left] - box.margin[:right] -
          box.border[:left] - box.border[:right] -
          box.padding[:left] - box.padding[:right]

        constrained_width =
          if border_box_sizing?(box)
            constrain_css_width(box, content_width + horizontal_box_edges(box), available_width)
          else
            constrain_css_width(box, content_width, available_width)
          end

        content_width_from_css_width(box, constrained_width)
      end

      def self.constrain_css_width(box, width, available_width)
        min_width = optional_width(box, "min-width", available_width)
        max_width = optional_width(box, "max-width", available_width)

        width = [width, min_width].max if min_width
        width = [width, max_width].min if max_width
        width
      end

      def self.optional_width(box, property, available_width)
        raw = style_value(box, property)
        return nil if raw.nil? || raw == "none" || raw == "auto"

        CSS::Values.resolve_length(raw, reference: available_width, default: 0)
      end

      def self.content_width_from_css_width(box, width)
        return width unless border_box_sizing?(box)

        width - horizontal_box_edges(box)
      end

      def self.declared_height(box)
        raw = style_value(box, "height")
        return box.height if raw.nil? || raw == "auto"

        CSS::Values.resolve_length(raw, default: box.height)
      end

      def self.content_height_from_css_height(box, height)
        content_height = border_box_sizing?(box) ? height - vertical_box_edges(box) : height

        [content_height, 0].max
      end

      def self.border_box_sizing?(box)
        style_value(box, "box-sizing") == "border-box"
      end

      def self.horizontal_box_edges(box)
        box.border[:left] + box.border[:right] + box.padding[:left] + box.padding[:right]
      end

      def self.vertical_box_edges(box)
        box.border[:top] + box.border[:bottom] + box.padding[:top] + box.padding[:bottom]
      end

      def self.preserve_assigned_width?(box, raw_width, available_width)
        return false if CSS::Values.reference_relative?(raw_width)

        available_width && box.width == available_width
      end

      def self.style_value(box, property)
        value = box.node&.computed_style&.[](property)
        return nil if value.to_s.strip.empty?

        value
      end
    end
  end
end
