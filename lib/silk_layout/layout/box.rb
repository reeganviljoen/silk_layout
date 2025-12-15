
# frozen_string_literal: true

module SilkLayout
  module Layout
    class Box
      attr_reader :node, :children

      def initialize(node)
        @node = node
        @children = []
      end

      def add_child(box)
        @children << box
      end
    end

    class BlockBox < Box; end
    class InlineBox < Box; end
    class AnonymousBlockBox < Box
      def initialize
        super(nil)
      end
    end
  end
end

