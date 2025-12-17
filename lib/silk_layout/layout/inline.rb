# frozen_string_literal: true

module SilkLayout
  module Layout
    class Inline < Box; end

    class TextBox < InlineBox
      attr_reader :text

      def initialize(text)
        super(nil)
        @text = text
      end
    end

    class LineBox < Box
      def initialize
        super(nil)
      end
    end
  end
end
