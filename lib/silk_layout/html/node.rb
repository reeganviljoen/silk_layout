# frozen_string_literal: true

module SilkLayout
  module HTML
    class Node
      attr_reader :tag, :attributes, :text
      attr_accessor :children, :parent
      attr_accessor :computed_style

      def initialize(tag:, attributes:, children:, text: nil, parent: nil)
        @tag = tag
        @attributes = attributes
        @children = children
        @text = text
        @parent = parent
      end

      def element?
        !tag.nil?
      end

      def self.from_nokogiri(node, parent = nil)
        if node.text?
          build_text_node(node, parent)
        else
          build_element_node(node, parent)
        end
      end

      def self.build_text_node(node, parent)
        text = node.text.strip
        return nil if text.empty?

        new(
          tag: nil,
          attributes: {},
          children: [],
          text: text,
          parent: parent
        )
      end

      def self.build_element_node(node, parent)
        element = new(
          tag: node.name,
          attributes: node.attributes.transform_values(&:value),
          children: [],
          parent: parent
        )

        element.children = node.children.map { |child| from_nokogiri(child, element) }.compact
        element
      end
    end
  end
end
