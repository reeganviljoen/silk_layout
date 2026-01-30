# frozen_string_literal: true

module SilkLayout
  module Layout
    class Inline < Box; end

    class TextBox < InlineBox
      attr_reader :text, :font_size, :font_family, :font_weight, :line_height

      def initialize(text, style)
        super(nil)
        @text = text

        @font_size = px(style["font-size"]) || 16
        @font_family = style["font-family"] || "Helvetica"
        @font_weight = style["font-weight"] || "normal"

        @line_height = (@font_size * 1.2).ceil
      end

      def children
        []
      end

      private

      def px(value)
        return nil unless value
        value.to_s.delete_suffix("px").to_i
      end
    end

    class LineBox < Box
      def initialize
        super(nil)
      end
    end
  end
end
