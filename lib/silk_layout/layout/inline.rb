# frozen_string_literal: true

module SilkLayout
  module Layout
    class Inline < Box; end

    class TextBox < InlineBox
      attr_reader :text,
        :font_size,
        :font_family,
        :font_weight,
        :font_style,
        :font_name,
        :line_height,
        :ascender,
        :descender,
        :color

      def initialize(text, style)
        super(nil)
        @text = text

        style ||= {}

        @font_size = px(style["font-size"]) || 16
        @font_family = style["font-family"] || "Helvetica"
        @font_weight = style["font-weight"] || "normal"
        @font_style = style["font-style"] || "normal"
        @color = style["color"] || "black"

        metrics = SilkLayout::Render::FontLibrary.metrics(
          @font_family,
          font_weight: @font_weight,
          font_style: @font_style
        )

        @font_name = metrics[:font_name]
        @ascender = metrics[:ascender] * @font_size / 1000.0
        @descender = metrics[:descender] * @font_size / 1000.0
        @line_height = parse_line_height(style["line-height"], @font_size)
      end

      def children
        []
      end

      def clone_with_text(text)
        self.class.new(text, {
          "font-size" => "#{@font_size}px",
          "font-family" => @font_family,
          "font-weight" => @font_weight,
          "font-style" => @font_style,
          "line-height" => "#{@line_height}px",
          "color" => @color
        })
      end

      private

      def px(value)
        return nil unless value

        value.to_s.delete_suffix("px").to_f
      end

      def parse_line_height(value, font_size)
        return (font_size * 1.2).round(2) if value.nil?

        raw = value.to_s.strip
        return (font_size * 1.2).round(2) if raw.empty? || raw == "normal"

        if raw.end_with?("px")
          raw.delete_suffix("px").to_f
        elsif raw.end_with?("%")
          font_size * raw.delete_suffix("%").to_f / 100.0
        else
          font_size * raw.to_f
        end
      end
    end

    class LineBox < Box
      def initialize
        super(nil)
      end
    end
  end
end
