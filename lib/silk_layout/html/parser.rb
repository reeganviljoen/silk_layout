# frozen_string_literal: true

require "nokogiri"

module SilkLayout
  module HTML
    class Parser
      def self.parse(html)
        document = Nokogiri::HTML(html)
        Node.from_nokogiri(document.root)
      end
    end
  end
end
