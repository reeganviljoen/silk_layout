# frozen_string_literal: true

module SilkLayout
  module Layout
    class Block < Box
      DEFAULT_LINE_HEIGHT = 18

      def layout(container_width)
        self.width = container_width

        if children.empty?
          layout_leaf
          return
        end

        cursor_y = 0

        children.each do |child|
          child.x = 0
          child.y = cursor_y
          child.layout(container_width)
          cursor_y += child.height
        end

        self.height = cursor_y
      end

      def layout_leaf
        self.height = DEFAULT_LINE_HEIGHT
      end
    end
  end
end
