# frozen_string_literal: true

require "crass"

module SilkLayout
  module CSS
    class Parser
      def self.parse_all(stylesheets)
        rules = []
        order = 0

        stylesheets.each do |css|
          Crass.parse(css).each do |node|
            next unless node[:node] == :style_rule

            selector_text = node[:selector][:value].strip
            selectors = selector_text.split(",").map(&:strip)

            declarations = {}

            node[:children].each do |child|
              next unless child[:node] == :property

              property = child[:name]
              value = child[:value]

              declarations[property] = Declaration.new(value: value, important: child[:important] ? true : false)
            end

            selectors.each do |raw_selector|
              selector = Selector.new(raw_selector)

              rules << Rule.new(
                selector: selector,
                declarations: declarations,
                specificity: selector.specificity,
                order: order,
                origin: :author
              )

              order += 1
            end
          end
        end

        rules
      end
    end
  end
end
