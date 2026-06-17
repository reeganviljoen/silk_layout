# frozen_string_literal: true

module SilkLayout
  module Layout
    class Engine
      DEFAULT_VIEWPORT_WIDTH = 800

      def self.layout(dom, css_rules, viewport_width: nil, page_size: nil)
        CSS::Cascade.apply(dom, css_rules)

        box_tree = FormattingBuilder.build(dom)

        root = Root.find(box_tree)

        context = Context.new(width: viewport_width || page_width(page_size) || DEFAULT_VIEWPORT_WIDTH, page_size: page_size)
        BlockLayout.layout(root, context)

        root
      end

      def self.page_width(page_size)
        case page_size
        when Array
          page_size[0]
        when Hash
          page_size[:width] || page_size["width"]
        end
      end
      private_class_method :page_width
    end
  end
end
