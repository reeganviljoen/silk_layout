# frozen_string_literal: true

module SilkLayout
  module Layout
    class Box
      attr_reader :node, :children
      attr_accessor :x, :y, :width, :height

      def initialize(node)
        @node = node
        @children = []
      end
    end
  end
end
