# frozen_string_literal: true

module SilkLayout
  module CSS
    class Cascade
      def self.apply(node, rules, parent_style = nil)
        matching = rules.select { |rule| rule.selector.match?(node) }
        matching.sort_by! { |rule| [rule.specificity, rule.order] }

        node.computed_style = ComputedStyle.new(matching, parent_style)

        node.children.each do |child|
          apply(child, rules, node.computed_style)
        end
      end

      def self.traverse(node, &block)
        yield node
        node.children.each { |child| traverse(child, &block) }
      end
    end
  end
end
