# frozen_string_literal: true

module SilkLayout
  module Layout
    class BlockLayout
      DEFAULT_LINE_HEIGHT = 16

      def self.layout(box, context, cursor_y = 0)
        box.x = 0
        box.y = cursor_y
        box.width = context.width

        current_y = box.y

        box.children.each do |child|
          if child.is_a?(BlockBox) || child.is_a?(AnonymousBlockBox)
            layout(child, context, current_y)
            current_y += child.height
          else
            # inline boxes: fixed line height placeholder
            child.x = 0
            child.y = current_y
            child.width = context.width
            child.height = DEFAULT_LINE_HEIGHT
            current_y += child.height
          end
        end

        box.height = current_y - box.y
      end
    end
  end
end
