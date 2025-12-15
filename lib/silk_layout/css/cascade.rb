# frozen_string_literal: true

module SilkLayout
  module CSS
    class Cascade
      def self.apply(node, rules)
        traverse(node) do |n|
          next unless n.element?
          n.computed_style = ComputedStyle.new(n, rules)
        end
      end

      def self.traverse(node, &block)
        yield node
        node.children.each { traverse(_1, &block) }
      end
    end
  end
end
