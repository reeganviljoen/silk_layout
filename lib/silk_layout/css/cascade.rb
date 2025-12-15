# frozen_string_literal: true

module SilkLayout
  module CSS
    class Cascade
      def self.apply(node, rules, parent_style = nil)
        node.children.each do |child|
          matching = rules.select { |rule| rule.selector.match?(child) }
          matching.sort_by! { |rule| [rule.specificity, rule.order] }

          child.computed_style = ComputedStyle.new(matching, parent_style)

          apply(child, rules, child.computed_style)
        end
      end

      def self.traverse(node, &block)
        yield node
        node.children.each { |child| traverse(child, &block) }
      end
    end
  end
end
