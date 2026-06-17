# frozen_string_literal: true

require_relative "../test_helper"

class RootTest < Minitest::Test
  def test_finds_body_without_dropping_body_children
    root = SilkLayout::Layout::Root.find(build_box_tree("<h1>A</h1><p>B</p>"))

    assert_equal "body", root.node.tag
    assert_equal ["h1", "p"], root.children.map { |child| child.node&.tag }
  end

  def test_engine_lays_out_all_top_level_body_children
    root = build_layout("<h1>A</h1><p>B</p>")

    assert_equal "body", root.node.tag
    assert_equal ["h1", "p"], root.children.map { |child| child.node&.tag }
    assert_equal [["A"], ["B"]], root.children.map { |child| line_texts(child) }
  end

  private

  def build_box_tree(body)
    dom, = SilkLayout::HTML::Parser.parse_document(html_document(body))
    SilkLayout::CSS::Cascade.apply(dom, [])
    SilkLayout::Layout::FormattingBuilder.build(dom)
  end

  def build_layout(body)
    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html_document(body))
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)
    SilkLayout::Layout::Engine.layout(dom, rules)
  end

  def html_document(body)
    <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{body}
        </body>
      </html>
    HTML
  end

  def line_texts(box, acc = [])
    acc << box.children.map(&:text).join if box.is_a?(SilkLayout::Layout::LineBox)
    box.children.each { |child| line_texts(child, acc) }
    acc
  end
end
