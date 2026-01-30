# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(rules, parent_style = nil)
        @values = {}
        @explicit_properties = {}

        rules.each do |rule|
          rule.declarations.each do |property, value|
            @values[property] = value
            @explicit_properties[property] = true
          end
        end

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

      def explicit_display?
        @explicit_properties.key?("display")
      end

      private

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
