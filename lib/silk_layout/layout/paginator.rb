# frozen_string_literal: true

module SilkLayout
  module Layout
    class Paginator
      def initialize(dom)
        @dom = dom
      end

      def pages
        root = Block.new(@dom)
        root.layout(595)

        pages = [Page.new]
        root.children.each do |box|
          if pages.last.fits?(box)
            pages.last.add(box)
          else
            pages << Page.new
            pages.last.add(box)
          end
        end

        pages
      end
    end
  end
end
