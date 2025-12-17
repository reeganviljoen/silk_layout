# frozen_string_literal: true

module SilkLayout
  module Layout
    class BlockLayout
      LINE_HEIGHT = 16
      DEFAULT_PADDING = 8
      DEFAULT_LINE_HEIGHT = 16
      

      def self.layout(box, context, cursor_y = 0)
        # --- Position this box (margin applies OUTSIDE)
        box.x = box.margin[:left]
        box.y = cursor_y + box.margin[:top]

        # --- Content box origin
        content_x =
          box.x + box.border[:left] + box.padding[:left]

        content_y =
          box.y + box.border[:top] + box.padding[:top]

        # --- Compute available width for content
        box.width =
          context.width -
          box.margin[:left] - box.margin[:right] -
          box.border[:left] - box.border[:right] -
          box.padding[:left] - box.padding[:right]

        current_y = content_y
        new_children = []
        inline_buffer = []

        box.children.each do |child|
          if child.is_a?(InlineBox)
            inline_buffer << child
            next
          end

          # Flush inline buffer into a line box
          if inline_buffer.any?
            line = layout_inline(inline_buffer, context, content_x, current_y)
            line.x = content_x
            line.y = current_y
            current_y += line.height
            new_children << line
            inline_buffer.clear
          end

          # Layout block child
          layout(child, context, current_y)
          current_y += child.height +
                      child.margin[:top] +
                      child.margin[:bottom]

          new_children << child
        end

        # Flush remaining inline content
        if inline_buffer.any?
          line = layout_inline(inline_buffer, context, content_x, current_y)
          line.x = content_x
          line.y = current_y
          current_y += line.height
          new_children << line
        end

        box.children = new_children

        # --- Final height includes padding + border
        content_height = current_y - content_y

        box.height =
          content_height +
          box.padding[:top] + box.padding[:bottom] +
          box.border[:top] + box.border[:bottom]
      end
     
      def self.layout_inline(inline_children, context, parent_x, parent_y)
        line = LineBox.new
        cursor_x = 0

        inline_children.each do |child|
          child.x = parent_x + cursor_x
          child.y = parent_y
          child.width = measure_text(child)
          child.height = LINE_HEIGHT

          cursor_x += child.width
          line.add_child(child)
        end

        line.width = cursor_x
        line.height = LINE_HEIGHT

        line
      end

      def self.has_text?(node)
        return false unless node
        return true if node.text

        node.children.any? { |c| has_text?(c) }
      end

      def self.measure_text(text_box)
        # temporary: fixed-width font assumption
        text_box.text.length * 8
      end

      private_class_method :layout_inline, :measure_text

      private_class_method :has_text?
    end
  end
end
