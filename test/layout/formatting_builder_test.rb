# frozen_string_literal: true

require_relative "../test_helper"

class FormattingBuilderTest < Minitest::Test
  def test_collapses_whitespace_only_text_between_inline_runs
    tree = build_tree("<p><span>Hello</span> \n <span>world</span></p>")

    assert_equal ["Hello", " ", "world"], text_boxes(tree).map(&:text)
  end

  def test_drops_indentation_whitespace_between_block_nodes
    tree = build_tree("<div>\n  <p>Hello</p>\n  <p>world</p>\n</div>")

    assert_equal ["Hello", "world"], text_boxes(tree).map(&:text)
  end

  def test_preserves_spaces_around_inline_elements
    tree = build_tree("<p>Hello <strong>world</strong> again</p>")

    assert_equal ["Hello ", "world", " again"], text_boxes(tree).map(&:text)
  end

  private

  def build_tree(body)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{body}
        </body>
      </html>
    HTML

    dom, = SilkLayout::HTML::Parser.parse_document(html)
    SilkLayout::CSS::Cascade.apply(dom, [])
    SilkLayout::Layout::FormattingBuilder.build(dom)
  end

  def text_boxes(box, acc = [])
    return acc unless box

    acc << box if box.is_a?(SilkLayout::Layout::TextBox)
    box.children.each { |child| text_boxes(child, acc) }
    acc
  end
end
