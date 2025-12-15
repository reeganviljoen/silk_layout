# frozen_string_literal: true

module SilkLayout
  module CSS
    class ComputedStyle
      def initialize(rules)
        @values = {}

        rules.each do |rule|
          rule.declarations.each do |property, value|
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
