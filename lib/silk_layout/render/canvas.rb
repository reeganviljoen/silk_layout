# frozen_string_literal: true

module SilkLayout
  module Render
    class Canvas
      def initialize(canvas)
        @canvas = canvas
      end

      def draw(page)
        page.boxes.each { draw_box(it) }
      end

      def draw_box(box)
        if box.node.text?
          @canvas.text(box.node.text.strip, at: [0, 800 - box.y], size: 12)
        end
        box.children.each { draw_box(it) }
      end
    end
  end
end
