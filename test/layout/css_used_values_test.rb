# frozen_string_literal: true

require_relative "../test_helper"

class CssUsedValuesTest < Minitest::Test
  def test_resolves_nested_percentage_width
    tree = build_layout(<<~HTML)
      <div style="width:400px">
        <div style="width:50%"></div>
      </div>
    HTML

    outer = tree.children.first
    child = outer.children.first

    assert_in_delta 400, outer.width, 0.01
    assert_in_delta 200, child.width, 0.01
  end

  def test_resolves_percentage_padding_and_margins_against_containing_width
    tree = build_layout(<<~HTML)
      <div style="width:400px">
        <div style="width:50%;padding-left:10%;padding-right:5%;margin-left:10%;margin-right:5%"></div>
      </div>
    HTML

    outer = tree.children.first
    child = outer.children.first

    assert_in_delta 40, child.margin[:left], 0.01
    assert_in_delta 20, child.margin[:right], 0.01
    assert_in_delta 40, child.padding[:left], 0.01
    assert_in_delta 20, child.padding[:right], 0.01
    assert_in_delta 40, child.x, 0.01
    assert_in_delta 260, child.width, 0.01
  end

  def test_resolves_calc_width_against_containing_width
    tree = build_layout(<<~HTML)
      <div style="width:300px">
        <div style="width:calc(100% - 20px)"></div>
      </div>
    HTML

    assert_in_delta 280, tree.children.first.children.first.width, 0.01
  end

  def test_border_box_width_includes_padding_and_border
    tree = build_layout(<<~HTML)
      <div style="width:200px;box-sizing:border-box;padding:20px;border:5px solid black">
        <div></div>
      </div>
    HTML

    outer = tree.children.first
    child = outer.children.first

    assert_in_delta 200, outer.width, 0.01
    assert_in_delta 25, child.x, 0.01
    assert_in_delta 150, child.width, 0.01
  end

  def test_applies_min_and_max_width_constraints
    minned = build_layout(<<~HTML, viewport_width: 400)
      <div style="width:50%;min-width:300px"></div>
    HTML

    maxed = build_layout(<<~HTML, viewport_width: 400)
      <div style="width:100%;max-width:240px">
        <div style="width:50%"></div>
      </div>
    HTML

    assert_in_delta 300, minned.children.first.width, 0.01
    assert_in_delta 240, maxed.children.first.width, 0.01
    assert_in_delta 120, maxed.children.first.children.first.width, 0.01
  end

  def test_flushes_inline_content_before_block_children
    tree = build_layout(<<~HTML)
      <div>
        hello
        <p>block</p>
        tail
      </div>
    HTML

    outer = tree.children.first

    assert_equal ["hello"], line_texts(outer.children[0])
    assert_equal "p", outer.children[1].node.tag
    assert_equal ["tail"], line_texts(outer.children[2])
  end

  def test_auto_border_box_width_accounts_for_edges
    tree = build_layout(<<~HTML, viewport_width: 300)
      <div style="box-sizing:border-box;padding-left:20px;padding-right:30px;border-left:5px solid black;border-right:10px solid black">
        <div></div>
      </div>
    HTML

    outer = tree.children.first
    child = outer.children.first

    assert_in_delta 300, outer.width, 0.01
    assert_in_delta 235, child.width, 0.01
  end

  private

  def build_layout(body, viewport_width: 800)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{body}
        </body>
      </html>
    HTML

    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html)
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)
    SilkLayout::Layout::Engine.layout(dom, rules, viewport_width: viewport_width)
  end

  def line_texts(box, acc = [])
    acc << box.children.map(&:text).join if box.is_a?(SilkLayout::Layout::LineBox)
    box.children.each { |child| line_texts(child, acc) }
    acc
  end
end
