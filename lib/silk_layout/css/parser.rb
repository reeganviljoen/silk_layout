# frozen_string_literal: true

require "css_parser"

module SilkLayout
  module CSS
    class Parser
      def self.parse_all(stylesheets)
        parser = CssParser::Parser.new
        stylesheets.each { |css| parser.add_block!(css) }
        parser
      end
    end
  end
end
