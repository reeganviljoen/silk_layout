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
        !tag.nil?
      end

      def self.from_nokogiri(node)
        if node.text?
          build_text_node(node)
        else
          build_element_node(node)
        end
      end

      # -----
      # Class helpers (intentionally public)
      # -----

      def self.build_text_node(node)
        text = node.text.strip
        return nil if text.empty?

        new(
          tag: nil,
          attributes: {},
          children: [],
          text: text
        )
      end

      def self.build_element_node(node)
        children = node.children.map { |child| from_nokogiri(child) }.compact

        new(
          tag: node.name,
          attributes: node.attributes.transform_values(&:value),
          children: children
        )
      end
    end
  end
end
