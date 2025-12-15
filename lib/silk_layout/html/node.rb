# frozen_string_literal: true

module SilkLayout
  module HTML
    class Node
      attr_reader :tag, :attributes, :children, :text
      attr_accessor :computed_style

      def initialize(tag:, attributes:, children:, text: nil)
        @tag = tag
        @attributes = attributes
        @children = children
        @text = text
      end

      def element?
        !@tag.nil?
      end

      def text?
        @tag.nil? && @text
      end

      def self.from_nokogiri(node)
        if node.text?
          new(tag: nil, attributes: {}, children: [], text: node.text)
        else
          new(
            tag: node.name,
            attributes: node.attributes.transform_values(&:value),
            children: node.children.map { from_nokogiri(_1) }
          )
        end
      end
    end
  end
end
