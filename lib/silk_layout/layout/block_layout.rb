# frozen_string_literal: true

module SilkLayout
  module Layout
    class BlockLayout
      def self.layout(box, context, cursor_y = 0, parent_x = 0, containing_width = nil)
        return FlexLayout.layout(box, context, cursor_y, parent_x, containing_width) if box.is_a?(FlexBox)

        box.x = parent_x + box.margin[:left]
        box.y = cursor_y + box.margin[:top]

        content_x =
          box.x + box.border[:left] + box.padding[:left]

        content_y =
          box.y + box.border[:top] + box.padding[:top]

        available_width = containing_width || context.width
        if box.explicit_width
          content_width = box.width
        else
          content_width =
            available_width -
            box.margin[:left] - box.margin[:right] -
            box.border[:left] - box.border[:right] -
            box.padding[:left] - box.padding[:right]
          content_width = 0 if content_width < 0
        end

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
        content_height = [content_height, box.height].max if box.explicit_height

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
    end
  end
end
