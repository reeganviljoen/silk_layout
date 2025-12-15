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

            # --- SELECTORS ---
            selector_text = node[:selector][:value].strip
            selectors = selector_text.split(",").map(&:strip)

            # --- DECLARATIONS ---
            declarations = {}

            node[:children].each do |child|
              next unless child[:node] == :property

              property = child[:name]
              value = child[:value]

              declarations[property] = value
            end

            selectors.each do |raw_selector|
              selector = Selector.new(raw_selector)

              rules << Rule.new(
                selector: selector,
                declarations: declarations,
                specificity: selector.specificity,
                order: order
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
