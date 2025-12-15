# frozen_string_literal: true

module SilkLayout
  module CSS
    class Selector
      def initialize(raw)
        @raw = raw.to_s.strip
      end

      def match?(node)
        return false unless node.element?
        return false if node.tag.nil?

        if id_selector?
          node.attributes["id"] == id_name
        elsif class_selector?
          node.attributes.fetch("class", "").split.include?(class_name)
        else
          node.tag == element_name
        end
      end

      def specificity
        if id_selector?
          [1, 0, 0]
        elsif class_selector?
          [0, 1, 0]
        else
          [0, 0, 1]
        end
      end

      private

      def id_selector?
        @raw.start_with?("#")
      end

      def class_selector?
        @raw.start_with?(".")
      end

      def id_name
        @raw[1..]
      end

      def class_name
        @raw[1..]
      end

      def element_name
        @raw
      end
    end
  end
end
