# frozen_string_literal: true

module SilkLayout
  module Layout
    class Engine
      DEFAULT_VIEWPORT_WIDTH = 800

      def self.layout(dom, css_rules, viewport_width: DEFAULT_VIEWPORT_WIDTH)
        CSS::Cascade.apply(dom, css_rules)

        box_tree = BoxBuilder.build(dom)

        root = Root.find(box_tree)

        context = Context.new(width: viewport_width)
        BlockLayout.layout(root, context)

        root
      end
    end
  end
end
