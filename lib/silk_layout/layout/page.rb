# frozen_string_literal: true

module SilkLayout
  module Layout
    class Page
      PAGE_HEIGHT = 842

      attr_reader :boxes

      def initialize
        @boxes = []
        @cursor = 0
      end

      def fits?(box)
        @cursor + box.height <= PAGE_HEIGHT
      end

      def add(box)
        box.y = @cursor
        @cursor += box.height
        @boxes << box
      end
    end
  end
end
