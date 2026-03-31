# frozen_string_literal: true

require_relative "../test_helper"

class BoxBuilderTest < Minitest::Test
  def test_delegates_to_formatting_builder
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          <p>Hello world</p>
        </body>
      </html>
    HTML

    dom, = SilkLayout::HTML::Parser.parse_document(html)
    SilkLayout::CSS::Cascade.apply(dom, [])

    built = SilkLayout::Layout::BoxBuilder.build(dom)
    formatted = SilkLayout::Layout::FormattingBuilder.build(dom)

    assert_equal formatted.class, built.class
    assert_equal formatted.node.tag, built.node.tag
  end
end
