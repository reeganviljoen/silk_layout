# frozen_string_literal: true

module SilkLayout
  module Layout
    class Engine
      DEFAULT_VIEWPORT_WIDTH = 800

      def self.layout(dom, css_rules, viewport_width: DEFAULT_VIEWPORT_WIDTH)
        # 1. Apply CSS cascade (top-down)
        CSS::Cascade.apply(dom, css_rules)

        # 2. Build box tree
        box_tree = BoxBuilder.build(dom)

        # 3. Perform block layout
        context = Context.new(width: viewport_width)
        BlockLayout.layout(box_tree, context)

        box_tree
      end
    end
  end
end
