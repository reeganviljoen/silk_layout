# frozen_string_literal: true

module SilkLayout
  module Layout
    class Root
      def self.find(box)
        return nil unless box
        return box unless box.node&.tag == "html"

        box.children.find { |child| child.node&.tag == "body" } || box
      end
    end
  end
end
