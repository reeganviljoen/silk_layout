# frozen_string_literal: true

require "crass"

module SilkLayout
  module CSS
    class Cascade
      def self.apply(node, rules, parent_style = nil)
        return unless node
        return unless node.respond_to?(:element?)

        matching = rules.select { |rule| rule.selector.match?(node) }

        inline = inline_rule(node)
        matching << inline if inline

        matching.sort_by! { |rule| [rule.specificity, rule.order] }

        node.computed_style = ComputedStyle.new(matching, parent_style)

        node.children.each do |child|
          apply(child, rules, node.computed_style)
        end
      end

      def self.inline_rule(node)
        return nil unless node.attributes

        style = node.attributes["style"].to_s.strip
        return nil if style.empty?

        declarations = {}
        Crass.parse_properties(style).each do |child|
          next unless child[:node] == :property

          declarations[child[:name]] = Declaration.new(value: child[:value], important: child[:important] ? true : false)
        end

        Rule.new(
          selector: nil,
          declarations: declarations,
          specificity: [1000, 0, 0],
          order: 1_000_000_000,
          origin: :author
        )
      end
    end
  end
end
