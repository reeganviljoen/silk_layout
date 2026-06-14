# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(rules, parent_style = nil)
        @values = {}
        @explicit_properties = {}

        apply_rules(rules)

        apply_inheritance(parent_style)
        apply_defaults
      end

      def [](property)
        @values[property]
      end

      def width
        @values["width"]
      end

      def explicit_width?
        value = @values["width"]
        value && value != "auto"
      end

      def explicit_height?
        value = @values["height"]
        value && value != "auto"
      end

      def explicit_display?
        @explicit_properties.key?("display")
      end

      private

      INLINE_SPECIFICITY = [1000, 0, 0].freeze

      def apply_rules(rules)
        winners = {}

        rules.each do |rule|
          spec = rule.specificity || INLINE_SPECIFICITY
          order = rule.order || 0

          rule.declarations.each do |property, decl|
            value = decl.is_a?(Declaration) ? decl.value : decl
            important = decl.is_a?(Declaration) ? decl.important : false

            key = [important ? 1 : 0, spec, order]
            current = winners[property]

            if current.nil? || (key <=> current[:key]) == 1
              winners[property] = {key: key, value: value}
              @explicit_properties[property] = true
            end
          end
        end

        winners.each do |prop, data|
          @values[prop] = data[:value]
        end
      end

      def apply_inheritance(parent)
        return unless parent

        Properties::INHERITED.each do |prop|
          @values[prop] ||= parent[prop]
        end
      end

      def apply_defaults
        Properties::DEFAULTS.each do |prop, value|
          @values[prop] ||= value
        end
      end
    end
  end
end
