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

        box.children.each do |child|
          if child.is_a?(BlockBox) || child.is_a?(AnonymousBlockBox)
            layout(child, context, current_y)
          else
            # inline boxes: fixed line height placeholder
            child.x = 0
            child.y = current_y
            child.width = context.width
            child.height = DEFAULT_LINE_HEIGHT
          end
          current_y += child.height
        end

        content_height = current_y - box.y

        # 🔑 If this block has text content, ensure it has height
        if content_height.zero? && has_text?(box.node)
          content_height = LINE_HEIGHT + DEFAULT_PADDING * 2
        end

        box.height = content_height
      end

      def self.has_text?(node)
        return false unless node
        return true if node.text

        node.children.any? { |c| has_text?(c) }
      end

      private_class_method :has_text?
    end
  end
end
