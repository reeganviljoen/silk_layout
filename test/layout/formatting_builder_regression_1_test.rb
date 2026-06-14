# frozen_string_literal: true

require_relative "../test_helper"

class FormattingBuilderRegression1Test < Minitest::Test
  # Regression: ISSUE-001 — styled text nodes ignored parent element typography
  # Found by /qa on 2026-03-31
  # Report: .gstack/qa-reports/qa-report-localhost-2026-03-31.md
  def test_text_nodes_inherit_parent_stylesheet_typography
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            p { font-size: 22px; }
          </style>
        </head>
        <body>
          <p>Inline style wins</p>
        </body>
      </html>
    HTML

    text_boxes = render_text_boxes(html)

    assert_equal [22.0, 22.0, 22.0, 22.0, 22.0], text_boxes.map(&:font_size)
  end

  # Regression: ISSUE-001 — styled text nodes ignored parent element typography
  # Found by /qa on 2026-03-31
  # Report: .gstack/qa-reports/qa-report-localhost-2026-03-31.md
  def test_text_nodes_inherit_parent_inline_styles
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          <p><span style="font-size: 32px">B</span></p>
        </body>
      </html>
    HTML

    text_boxes = render_text_boxes(html)

    assert_equal [32.0], text_boxes.map(&:font_size)
  end

  private

  def render_text_boxes(html)
    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html)
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)
    tree = SilkLayout::Layout::Engine.layout(dom, rules)

    text_boxes(tree)
  end

  def text_boxes(box, acc = [])
    acc << box if box.is_a?(SilkLayout::Layout::TextBox)
    box.children.each { |child| text_boxes(child, acc) }
    acc
  end
end
