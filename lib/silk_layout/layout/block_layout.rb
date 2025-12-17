# frozen_string_literal: true

module SilkLayout
  module Layout
    class BlockLayout
      LINE_HEIGHT = 16
      DEFAULT_PADDING = 8
      DEFAULT_LINE_HEIGHT = 16

      def self.layout(box, context, cursor_y = 0)
        box.x = 0
        box.y = cursor_y
        box.width = context.width

        current_y = box.y

        new_children = []
        inline_buffer = []

        box.children.each do |child|
          if child.is_a?(InlineBox)
            inline_buffer << child
          else
            # flush inline buffer into a line box
            if inline_buffer.any?
              line = layout_inline(inline_buffer, context, box.x, current_y)
              line.x = 0
              line.y = current_y
              current_y += line.height
              new_children << line
              inline_buffer.clear
            end

            # normal block child
            layout(child, context, current_y)
            current_y += child.height
            new_children << child
          end
        end

        # flush remaining inline content
        if inline_buffer.any?
          line = layout_inline(inline_buffer, context, box.x, current_y)
          line.x = 0
          line.y = current_y
          current_y += line.height
          new_children << line
        end

        box.children = new_children
        box.height = current_y - box.y

        content_height = current_y - box.y

        # 🔑 If this block has text content, ensure it has height
        if content_height.zero? && has_text?(box.node)
          content_height = LINE_HEIGHT + DEFAULT_PADDING * 2
        end

        box.height = content_height
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
