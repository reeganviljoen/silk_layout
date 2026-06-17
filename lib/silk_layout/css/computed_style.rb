# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(rules, parent_style = nil)
        @values = {}
        @explicit_properties = {}

        apply_rules(rules, parent_style)

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

      def apply_rules(rules, parent_style)
        winners = {}

        rules.each do |rule|
          spec = rule.specificity || INLINE_SPECIFICITY
          order = rule.order || 0

          each_declaration(rule.declarations).each_with_index do |(property, decl), declaration_index|
            value = decl.is_a?(Declaration) ? decl.value : decl
            important = decl.is_a?(Declaration) ? decl.important : false

            Properties.expand_declaration(property, value).each_with_index do |(expanded_property, expanded_value), expansion_index|
              key = [important ? 1 : 0, spec, order, declaration_index, expansion_index]
              current = winners[expanded_property]

              if current.nil? || (key <=> current[:key]) == 1
                winners[expanded_property] = {key: key, value: expanded_value}
                @explicit_properties[expanded_property] = true
              end
            end
          end
        end

        winners.each do |prop, data|
          @values[prop] = resolve_css_wide(prop, data[:value], parent_style)
        end
      end

      def apply_inheritance(parent)
        return unless parent

        Properties::INHERITED.each do |prop|
          @values[prop] = parent[prop] unless @values.key?(prop)
        end
      end

      def apply_defaults
        Properties::DEFAULTS.each do |prop, value|
          @values[prop] = value unless @values.key?(prop)
        end
      end

      def each_declaration(declarations)
        return enum_for(:each_declaration, declarations) unless block_given?

        declarations.each do |property, declaration|
          yield property, declaration
        end
      end

      def resolve_css_wide(property, value, parent)
        return value unless Properties.css_wide_keyword?(value)
        return value unless Properties.known?(property)

        case value.to_s.strip.downcase
        when "inherit"
          inherited_value(property, parent)
        when "initial"
          Properties.initial_value(property)
        when "unset"
          if Properties.inherited?(property)
            inherited_value(property, parent)
          else
            Properties.initial_value(property)
          end
        end
      end

      def inherited_value(property, parent)
        parent&.[](property) || Properties.initial_value(property)
      end
    end
  end
end
