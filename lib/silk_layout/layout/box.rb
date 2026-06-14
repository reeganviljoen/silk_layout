# frozen_string_literal: true

module SilkLayout
  module Layout
    class Box
      attr_accessor :x,
        :y,
        :width,
        :height,
        :children,
        :node,
        :margin,
        :padding,
        :border,
        :border_color,
        :background_color,
        :explicit_width,
        :explicit_height,
        :flex,
        :display,
        :has_border

      def initialize(node)
        @node = node
        @children = []

        @x = 0
        @y = 0
        @width = 0
        @height = 0

        @margin = {top: 0, right: 0, bottom: 0, left: 0}
        @padding = {top: 0, right: 0, bottom: 0, left: 0}
        @border = {top: 0, right: 0, bottom: 0, left: 0}
        @border_color = {
          top: nil,
          right: nil,
          bottom: nil,
          left: nil
        }
        @background_color = nil

        @explicit_width = false
        @explicit_height = false
        @flex = {}
        @display = nil
      end

      def add_child(box)
        @children << box
      end

      def border_box_x
        x
      end

      def border_box_y
        y
      end

      def border_box_width
        width
      end

      def border_box_height
        height
      end
    end

    class BlockBox < Box; end
    class FlexBox < BlockBox; end
    class InlineBox < Box; end

    class AnonymousBlockBox < Box
      def initialize
        super(nil)
      end
    end
  end
end
