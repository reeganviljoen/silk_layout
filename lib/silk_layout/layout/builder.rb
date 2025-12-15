# frozen_string_literal: true

module SilkLayout
  module Layout
    class Builder
      def self.build(node)
        return nil unless node.element?
        return nil if node.computed_style&.[]("display") == "none"

        box = Block.new(node)

        node.children.each do |child|
          child_box = build(child)
          box.children << child_box if child_box
        end

        box
      end
    end
  end
end
