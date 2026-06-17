# frozen_string_literal: true

module SilkLayout
  module CSS
    module Properties
      EDGES = %w[
        top
        right
        bottom
        left
      ].freeze

      BORDER_PARTS = %w[
        width
        style
        color
      ].freeze

      CSS_WIDE_KEYWORDS = %w[
        inherit
        initial
        unset
      ].freeze

      INHERITED = %w[
        color
        font-size
        font-family
        font-weight
        font-style
        line-height
      ].freeze

      SPACING_INITIALS = %w[
        margin
        padding
      ].flat_map do |property|
        EDGES.map { |side| ["#{property}-#{side}", "0"] }
      end.to_h.freeze

      BORDER_INITIALS = EDGES.flat_map do |side|
        [
          ["border-#{side}-width", "medium"],
          ["border-#{side}-style", "none"],
          ["border-#{side}-color", "black"]
        ]
      end.to_h.freeze

      INITIAL_VALUES = {
        "color" => "black",
        "font-size" => "16px",
        "font-family" => "Helvetica",
        "font-weight" => "normal",
        "font-style" => "normal",
        "line-height" => "normal",
        "display" => "inline",
        "width" => "auto",
        "height" => "auto",
        "box-sizing" => "content-box",
        "min-width" => "0",
        "max-width" => "none",
        "background-color" => "transparent",
        "flex-direction" => "row",
        "flex-wrap" => "nowrap",
        "justify-content" => "flex-start",
        "align-items" => "stretch",
        "flex-grow" => "0",
        "flex-shrink" => "1",
        "flex-basis" => "auto",
        "row-gap" => "0",
        "column-gap" => "0"
      }.merge(SPACING_INITIALS).merge(BORDER_INITIALS).freeze

      DEFAULTS = INITIAL_VALUES
      KNOWN = INITIAL_VALUES.keys.freeze

      def self.expand_declaration(property, value)
        property = property.to_s.downcase
        value = value.to_s.strip
        expanded = [[property, value]]

        expanded.concat(
          if css_wide_keyword?(value)
            css_wide_expansion(property, value)
          else
            shorthand_expansion(property, value)
          end
        )
      end

      def self.css_wide_keyword?(value)
        CSS_WIDE_KEYWORDS.include?(value.to_s.strip.downcase)
      end

      def self.initial_value(property)
        INITIAL_VALUES[property]
      end

      def self.known?(property)
        KNOWN.include?(property)
      end

      def self.inherited?(property)
        INHERITED.include?(property)
      end

      def self.css_wide_expansion(property, value)
        case property
        when "margin", "padding"
          EDGES.map { |side| ["#{property}-#{side}", value] }
        when "border"
          all_border_longhands(value)
        when "border-width", "border-style", "border-color"
          border_edge_longhands(property.delete_prefix("border-"), value)
        when /\Aborder-(top|right|bottom|left)\z/
          border_side_longhands(Regexp.last_match(1), value)
        when "background"
          [["background-color", value]]
        when "flex"
          flex_longhands(value, value, value)
        when "flex-flow"
          flex_flow_longhands(value, value)
        when "gap"
          gap_longhands(value, value)
        else
          []
        end
      end

      def self.shorthand_expansion(property, value)
        case property
        when "margin", "padding"
          edge_values(value).map { |side, side_value| ["#{property}-#{side}", side_value] }
        when "border"
          parsed = border_shorthand(value)
          all_border_longhands do |side, part|
            parsed[part] || INITIAL_VALUES.fetch("border-#{side}-#{part}")
          end
        when "border-width", "border-style", "border-color"
          part = property.delete_prefix("border-")
          edge_values(value).map { |side, side_value| ["border-#{side}-#{part}", side_value] }
        when /\Aborder-(top|right|bottom|left)\z/
          side = Regexp.last_match(1)
          parsed = border_shorthand(value)
          border_side_longhands(side) do |part|
            parsed[part] || INITIAL_VALUES.fetch("border-#{side}-#{part}")
          end
        when "background"
          [["background-color", background_color(value)]]
        when "flex"
          flex_shorthand(value).map { |part, part_value| ["flex-#{part}", part_value] }
        when "flex-flow"
          flex_flow(value).map { |part, part_value| ["flex-#{part}", part_value] }
        when "gap"
          gap_values(value)
        else
          []
        end
      end

      def self.edge_values(value)
        tokens = split_tokens(value)
        values =
          case tokens.length
          when 0
            []
          when 1
            [tokens[0], tokens[0], tokens[0], tokens[0]]
          when 2
            [tokens[0], tokens[1], tokens[0], tokens[1]]
          when 3
            [tokens[0], tokens[1], tokens[2], tokens[1]]
          else
            [tokens[0], tokens[1], tokens[2], tokens[3]]
          end

        EDGES.zip(values).to_h
      end

      def self.all_border_longhands(value = nil)
        EDGES.flat_map do |side|
          BORDER_PARTS.map do |part|
            ["border-#{side}-#{part}", block_given? ? yield(side, part) : value]
          end
        end
      end

      def self.border_edge_longhands(part, value)
        EDGES.map { |side| ["border-#{side}-#{part}", value] }
      end

      def self.border_side_longhands(side, value = nil)
        BORDER_PARTS.map do |part|
          ["border-#{side}-#{part}", block_given? ? yield(part) : value]
        end
      end

      def self.border_shorthand(value)
        split_tokens(value).each_with_object({}) do |token, parsed|
          if border_width?(token)
            parsed["width"] ||= token
          elsif border_style?(token)
            parsed["style"] ||= token
          else
            parsed["color"] ||= token
          end
        end
      end

      def self.background_color(value)
        split_tokens(value).find { |token| color_token?(token) } || INITIAL_VALUES.fetch("background-color")
      end

      def self.flex_shorthand(value)
        tokens = split_tokens(value)

        case tokens.join(" ")
        when "none"
          {"grow" => "0", "shrink" => "0", "basis" => "auto"}
        when "auto"
          {"grow" => "1", "shrink" => "1", "basis" => "auto"}
        else
          numbers = tokens.select { |token| numeric?(token) }
          basis = tokens.find { |token| !numeric?(token) }

          {
            "grow" => numbers[0] || "1",
            "shrink" => numbers[1] || "1",
            "basis" => basis || (numbers.any? ? "0px" : "auto")
          }
        end
      end

      def self.flex_longhands(grow, shrink, basis)
        [
          ["flex-grow", grow],
          ["flex-shrink", shrink],
          ["flex-basis", basis]
        ]
      end

      def self.flex_flow(value)
        parsed = split_tokens(value).each_with_object({}) do |token, acc|
          if %w[row row-reverse column column-reverse].include?(token)
            acc["direction"] = token
          elsif %w[nowrap wrap wrap-reverse].include?(token)
            acc["wrap"] = token
          end
        end

        {
          "direction" => parsed["direction"] || INITIAL_VALUES.fetch("flex-direction"),
          "wrap" => parsed["wrap"] || INITIAL_VALUES.fetch("flex-wrap")
        }
      end

      def self.flex_flow_longhands(direction, wrap)
        [
          ["flex-direction", direction],
          ["flex-wrap", wrap]
        ]
      end

      def self.gap_values(value)
        values = split_tokens(value)
        row = values[0] || INITIAL_VALUES.fetch("row-gap")
        column = values[1] || row

        gap_longhands(row, column)
      end

      def self.gap_longhands(row, column)
        [
          ["row-gap", row],
          ["column-gap", column]
        ]
      end

      def self.split_tokens(value)
        Values.split_tokens(value)
      end

      def self.numeric?(value)
        value.to_s.match?(/\A[-+]?\d*\.?\d+\z/)
      end

      def self.border_width?(value)
        value.to_s.match?(/\A[-+]?\d*\.?\d+(?:px)?\z/) || %w[thin medium thick].include?(value.to_s)
      end

      def self.border_style?(value)
        %w[
          none
          hidden
          dotted
          dashed
          solid
          double
          groove
          ridge
          inset
          outset
        ].include?(value.to_s)
      end

      def self.color_token?(value)
        raw = value.to_s.strip
        return false if raw.empty?
        return true if raw.start_with?("#")
        return true if SilkLayout::CSS::Color.parse(raw)
        return false if %w[none transparent inherit initial unset].include?(raw)

        !border_width?(raw) && !border_style?(raw) && !raw.include?("(") && !raw.include?("/")
      end
    end
  end
end
