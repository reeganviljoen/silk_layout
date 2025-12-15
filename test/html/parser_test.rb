# frozen_string_literal: true

class HTMLParserTest < Minitest::Test
  def test_parses_html
    node = SilkLayout::HTML::Parser.parse("<p>Hello</p>")
    refute_nil node
  end
end
