# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(rules, parent_style = nil, node_tag = nil)
        @values = {}

        rules.each do |rule|
          rule.declarations.each do |property, value|
            @values[property] = value
          end
        end

        apply_inheritance(parent_style)
        apply_html_element_defaults(node_tag)
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

      def apply_html_element_defaults(node_tag)
        return unless node_tag
        return unless Properties::HTML_ELEMENT_DEFAULTS.key?(node_tag)

        element_defaults = Properties::HTML_ELEMENT_DEFAULTS[node_tag]
        element_defaults.each do |prop, value|
          @values[prop] ||= value
        end
      end
    end
  end
end
