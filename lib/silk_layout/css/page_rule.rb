# frozen_string_literal: true

module SilkLayout
  module CSS
    class PageRule
      CSS_PX_PER_IN = 96.0
      MM_PER_IN = 25.4
      A4 = [(210.0 / MM_PER_IN) * CSS_PX_PER_IN, (297.0 / MM_PER_IN) * CSS_PX_PER_IN].freeze
      NAMED_SIZES = {
        "a4" => A4
      }.freeze
      ORIENTATIONS = %w[
        landscape
        portrait
      ].freeze

      attr_reader :selector, :declarations, :order

      def self.resolve_page_size(page_rules)
        page_rules
          .select { |rule| rule.selector.to_s.empty? }
          .sort_by(&:order)
          .filter_map(&:size)
          .last
      end

      def self.parse_size(value)
        tokens = value.to_s.strip.split(/\s+/)
        return nil if tokens.empty?

        orientation = tokens.find { |token| ORIENTATIONS.include?(token.downcase) }&.downcase
        size_tokens = tokens.reject { |token| ORIENTATIONS.include?(token.downcase) }
        dimensions = named_dimensions(size_tokens) || length_dimensions(size_tokens)
        return nil unless dimensions

        orient(dimensions, orientation)
      end

      def self.named_dimensions(tokens)
        return nil unless tokens.length == 1

        named = NAMED_SIZES[tokens[0].downcase]
        named&.dup
      end

      def self.length_dimensions(tokens)
        return nil unless tokens.length.between?(1, 2)

        lengths = tokens.map { |token| length_to_px(token) }
        return nil if lengths.any?(&:nil?)

        [lengths[0], lengths[1] || lengths[0]]
      end

      def self.length_to_px(token)
        match = token.to_s.match(/\A([-+]?\d*\.?\d+)(px|in)\z/i)
        return nil unless match

        value = match[1].to_f
        return nil unless value.positive?

        (match[2].downcase == "in") ? value * CSS_PX_PER_IN : value
      end

      def self.orient(dimensions, orientation)
        case orientation
        when "landscape"
          (dimensions[0] > dimensions[1]) ? dimensions : dimensions.reverse
        when "portrait"
          (dimensions[0] < dimensions[1]) ? dimensions : dimensions.reverse
        else
          dimensions
        end
      end

      def initialize(selector:, declarations:, order:)
        @selector = selector
        @declarations = declarations
        @order = order
      end

      def size
        declaration = declarations.rfind { |property, _declaration| property == "size" }
        return nil unless declaration

        self.class.parse_size(declaration[1].value)
      end
    end
  end
end
