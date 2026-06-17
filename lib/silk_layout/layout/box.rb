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
        :has_border,
        :replaced,
        :image_source,
        :image_resource,
        :intrinsic_width,
        :intrinsic_height

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
        @replaced = false
        @image_source = nil
        @image_resource = nil
        @intrinsic_width = nil
        @intrinsic_height = nil
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

      def content_box_x
        x + border[:left] + padding[:left]
      end

      def content_box_y
        y + border[:top] + padding[:top]
      end

      def content_box_width
        [width - border[:left] - border[:right] - padding[:left] - padding[:right], 0].max
      end

      def content_box_height
        [height - border[:top] - border[:bottom] - padding[:top] - padding[:bottom], 0].max
      end

      def replaced?
        replaced
      end

      def image?
        !image_resource.nil?
      end

      def image_path
        image_resource&.path
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
