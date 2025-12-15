# frozen_string_literal: true

module SilkLayout
  module Layout
    class Block < Box
      def layout(container_width)
        self.width = container_width
        cursor = 0

        children.each do |child|
          child.x = 0
          child.y = cursor
          child.layout(container_width)
          cursor += child.height
        end

        self.height = cursor
      end
    end
  end
end
