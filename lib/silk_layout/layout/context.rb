# frozen_string_literal: true

module SilkLayout
  module Layout
    class Context
      attr_reader :width, :page_size

      def initialize(width:, page_size: nil)
        @width = width
        @page_size = page_size
      end

      def viewport_width
        width
      end
    end
  end
end
