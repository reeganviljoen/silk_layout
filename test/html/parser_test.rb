# frozen_string_literal: true

require "test_helper"

class HTMLParserTest < Minitest::Test
  def test_parses_html
    node = SilkLayout::HTML::Parser.parse("<p>Hello</p>")

    refute_nil node
    assert node.element?

    body = node.children.find { |child| child.tag == "body" }
    refute_nil body

    paragraph = body.children.find { |child| child.tag == "p" }
    refute_nil paragraph
  end

  def test_text_node
    node = SilkLayout::HTML::Parser.parse("<p>Hello</p>")
    body = node.children.find { |child| child.tag == "body" }
    paragraph = body.children.find { |child| child.tag == "p" }
    text_node = paragraph.children.first

    assert text_node.text?
    assert_equal "Hello", text_node.text
  end

  def test_ignores_whitespace_text_nodes
    node = SilkLayout::HTML::Parser.parse("<p>\n  Hello \n</p>")
    body = node.children.find { |child| child.tag == "body" }
    paragraph = body.children.find { |child| child.tag == "p" }

    assert_equal 1, paragraph.children.size
    assert_equal "Hello", paragraph.children.first.text
  end
end
