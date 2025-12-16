# frozen_string_literal: true

module SilkLayout
  module Layout
    class Root
      def self.find(box)
        current = box
        while current.node&.tag == "html" || current.node&.tag == "body"
          current = current.children.first
        end
        current
      end
    end
  end
end
