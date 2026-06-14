# frozen_string_literal: true

require_relative "../test_helper"

class BoxModelShorthandTest < Minitest::Test
  def test_expands_margin_and_padding_shorthands
    tree = build_tree(<<~HTML)
      <div style="display:block;margin:1px 2px 3px 4px;padding:5px 6px">Hello</div>
    HTML

    assert_equal({top: 1, right: 2, bottom: 3, left: 4}, tree.margin)
    assert_equal({top: 5, right: 6, bottom: 5, left: 6}, tree.padding)
  end

  def test_expands_border_shorthand
    tree = build_tree(<<~HTML)
      <div style="display:block;border:2px solid red;border-left:4px solid blue">Hello</div>
    HTML

    assert_equal({top: 2, right: 2, bottom: 2, left: 4}, tree.border)
    assert_equal :red, tree.border_color[:top]
    assert_equal :blue, tree.border_color[:left]
  end

  def test_expands_three_value_spacing_shorthand
    tree = build_tree(<<~HTML)
      <div style="display:block;margin:1px 2px 3px">Hello</div>
    HTML

    assert_equal({top: 1, right: 2, bottom: 3, left: 2}, tree.margin)
  end

  def test_parses_named_border_widths
    tree = build_tree(<<~HTML)
      <div style="display:block;border:thin dotted green;border-right-width:thick">Hello</div>
    HTML

    assert_equal 1, tree.border[:top]
    assert_equal 5, tree.border[:right]
    assert_equal :green, tree.border_color[:bottom]
  end

  def test_reads_background_color
    tree = build_tree(<<~HTML)
      <div style="display:block;background-color:lightblue">Hello</div>
    HTML

    assert_equal :lightblue, tree.background_color
  end

  def test_reads_background_shorthand_color
    tree = build_tree(<<~HTML)
      <div style="display:block;background:#cc0000">Hello</div>
    HTML

    assert_equal :"#cc0000", tree.background_color
  end

  def test_parses_flex_keywords_and_flow
    auto = build_tree(<<~HTML)
      <div style="display:flex;flex:auto;flex-flow:column wrap">Hello</div>
    HTML

    none = build_tree(<<~HTML)
      <div style="display:flex;flex:none">Hello</div>
    HTML

    initial = build_tree(<<~HTML)
      <div style="display:flex;flex:initial">Hello</div>
    HTML

    assert_equal 1, auto.flex[:grow]
    assert_equal "column", auto.flex[:direction]
    assert_equal "wrap", auto.flex[:wrap]
    assert_equal 0, none.flex[:grow]
    assert_equal 0, none.flex[:shrink]
    assert_equal 0, initial.flex[:grow]
    assert_equal 1, initial.flex[:shrink]
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
    SilkLayout::Layout::Root.find(SilkLayout::Layout::FormattingBuilder.build(dom))
  end
end
