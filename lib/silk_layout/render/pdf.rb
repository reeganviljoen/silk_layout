# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class PDF
      def initialize(io)
        @doc = HexaPDF::Document.new
        @io = io
      end

      def render(page)
        pdf_page = @doc.pages.add
        canvas = pdf_page.canvas
        Canvas.new(canvas).draw(page)
      end

      def finish
        @doc.write(@io)
      end
    end
  end
end
