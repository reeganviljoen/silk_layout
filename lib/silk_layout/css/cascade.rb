# frozen_string_literal: true

module SilkLayout
  module CSS
    class Cascade
      def self.apply(node, rules)
        traverse(node) do |n|
          next unless n.element?

          matching = rules.select { |rule| rule.selector.match?(n) }

          matching.sort_by! do |rule|
            [rule.specificity, rule.order]
          end

          n.computed_style = ComputedStyle.new(matching)
        end
      end

      def self.traverse(node, &block)
        yield node
        node.children.each { |child| traverse(child, &block) }
      end
    end
  end
end
