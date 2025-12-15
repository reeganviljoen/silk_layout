# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(node, rules)
        @values = {}
        # Placeholder: real selector matching & specificity later
        rules.each_rule_set do |_selectors, declarations|
          declarations.each do |property, value|
            @values[property] = value
          end
        end
      end

      def [](property)
        @values[property]
      end
    end
  end
end
