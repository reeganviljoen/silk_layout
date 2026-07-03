# frozen_string_literal: true

require_relative "../test_helper"

class InlineFormatterTest < Minitest::Test
  def test_font_metrics_measurement_uses_real_glyph_widths
    wide = SilkLayout::Render::FontLibrary.measure_text(
      "WWW",
      font_size: 16,
      font_family: "Helvetica"
    )
    narrow = SilkLayout::Render::FontLibrary.measure_text(
      "iii",
      font_size: 16,
      font_family: "Helvetica"
    )

    assert_operator wide, :>, narrow
  end

  def test_wraps_text_across_multiple_lines
    tree = build_layout("<p>Hello world again</p>", viewport_width: 60)

    assert_equal ["Hello", "world", "again"], line_texts(tree)
  end

  def test_keeps_spaces_between_words_on_same_line
    tree = build_layout("<p>Hello world again</p>", viewport_width: 85)

    assert_equal ["Hello world", "again"], line_texts(tree)
  end

  def test_flattens_nested_inline_nodes_when_wrapping
    tree = build_layout("<p>Hello <span>world</span> again</p>", viewport_width: 85)

    assert_equal ["Hello world", "again"], line_texts(tree)
  end

  def test_break_element_flushes_current_line
    tree = build_layout("<p>Hello<br>world</p>", viewport_width: 300)

    assert_equal ["Hello", "world"], line_texts(tree)
  end

  def test_leading_whitespace_is_trimmed_from_inline_run
    tree = build_layout("<p> Hello</p>", viewport_width: 300)

    assert_equal ["Hello"], line_texts(tree)
  end

  private

  def build_layout(body, viewport_width:)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{body}
        </body>
      </html>
    HTML

    dom, = SilkLayout::HTML::Parser.parse_document(html)
    SilkLayout::Layout::Engine.layout(dom, [], viewport_width: viewport_width)
  end

  def line_texts(box, acc = [])
    acc << box.children.map(&:text).join if box.is_a?(SilkLayout::Layout::LineBox)
    box.children.each { |child| line_texts(child, acc) }
    acc
  end
end
