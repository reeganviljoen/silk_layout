# frozen_string_literal: true

module SilkLayout
  module Layout
    class Context
      attr_reader :width

      def initialize(width:)
        @width = width
      end
    end
  end
end
