# frozen_string_literal: true

module SilkLayout
  module Layout
    class BoxBuilder
      def self.build(dom_root)
        FormattingBuilder.build(dom_root)
      end
    end
  end
end
