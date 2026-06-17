# frozen_string_literal: true

require_relative "../test_helper"

class FlexLayoutTest < Minitest::Test
  def test_builds_flex_container_from_display_flex
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:300px;gap:10px">
        <div style="width:50px">A</div>
        <div style="width:50px">B</div>
      </div>
    HTML

    assert_instance_of SilkLayout::Layout::FlexBox, tree
    assert_equal 50, tree.children[0].width
    assert_equal 50, tree.children[1].width
    assert_equal 0, tree.children[0].x
    assert_equal 60, tree.children[1].x
  end

  def test_distributes_flex_grow_space
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:300px">
        <div style="flex:1">A</div>
        <div style="flex:2">B</div>
      </div>
    HTML

    assert_in_delta 100, tree.children[0].width, 0.01
    assert_in_delta 200, tree.children[1].width, 0.01
    assert_in_delta 100, tree.children[1].x, 0.01
  end

  def test_honors_justify_content_center
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:300px;gap:10px;justify-content:center">
        <div style="width:50px">A</div>
        <div style="width:50px">B</div>
      </div>
    HTML

    assert_in_delta 95, tree.children[0].x, 0.01
    assert_in_delta 155, tree.children[1].x, 0.01
  end

  def test_honors_align_items_center
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:200px;height:100px;align-items:center">
        <div style="width:50px;height:20px">A</div>
      </div>
    HTML

    assert_in_delta 40, tree.children[0].y, 0.01
  end

  def test_wraps_flex_rows
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:120px;gap:10px;flex-wrap:wrap">
        <div style="width:60px">A</div>
        <div style="width:60px">B</div>
        <div style="width:60px">C</div>
      </div>
    HTML

    assert_equal 0, tree.children[0].x
    assert_equal 0, tree.children[1].x
    assert_operator tree.children[1].y, :>, tree.children[0].y
    assert_operator tree.children[2].y, :>, tree.children[1].y
  end

  def test_columns_use_main_axis_justification
    tree = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:100px;height:120px;gap:10px;justify-content:space-between">
        <div style="height:20px">A</div>
        <div style="height:20px">B</div>
      </div>
    HTML

    assert_in_delta 0, tree.children[0].y, 0.01
    assert_in_delta 100, tree.children[1].y, 0.01
  end

  def test_uses_available_width_without_explicit_container_width
    tree = build_layout(<<~HTML, viewport_width: 240)
      <div style="display:flex;padding:10px">
        <div style="flex:1">A</div>
      </div>
    HTML

    assert_in_delta 240, tree.width, 0.01
    assert_in_delta 220, tree.children[0].width, 0.01
    assert_in_delta 10, tree.children[0].x, 0.01
  end

  def test_shrinks_items_when_row_overflows
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:100px">
        <div style="width:80px">A</div>
        <div style="width:80px">B</div>
      </div>
    HTML

    assert_in_delta 50, tree.children[0].width, 0.01
    assert_in_delta 50, tree.children[1].width, 0.01
  end

  def test_row_reverse_positions_items_in_reverse_order
    tree = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:row-reverse;width:120px">
        <div style="width:40px">A</div>
        <div style="width:40px">B</div>
      </div>
    HTML

    item_a = child_by_text(tree, "A")
    item_b = child_by_text(tree, "B")

    assert_in_delta 40, item_a.x, 0.01
    assert_in_delta 0, item_b.x, 0.01
  end

  def test_inline_flex_shrinks_to_items
    tree = build_layout(<<~HTML)
      <div style="display:inline-flex;gap:5px">
        <div style="width:20px">A</div>
        <div style="width:30px">B</div>
      </div>
    HTML

    assert_in_delta 55, tree.width, 0.01
  end

  def test_intrinsic_item_width_uses_text_width
    tree = build_layout(<<~HTML)
      <div style="display:inline-flex">
        <div>Wide text</div>
      </div>
    HTML

    expected = SilkLayout::Render::FontLibrary.measure_text("Wide text", font_size: 16, font_family: "Helvetica")

    assert_in_delta expected, tree.children[0].width, 0.01
    assert_in_delta expected, tree.width, 0.01
  end

  def test_flex_basis_sets_base_size
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:120px">
        <div style="flex:0 0 30px">A</div>
        <div style="flex:0 0 40px">B</div>
      </div>
    HTML

    assert_in_delta 30, tree.children[0].width, 0.01
    assert_in_delta 40, tree.children[1].width, 0.01
  end

  def test_empty_flex_container_has_no_content_height
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:120px"></div>
    HTML

    assert_equal 0, tree.height
  end

  def test_justify_content_variants
    flex_end = build_layout(<<~HTML)
      <div style="display:flex;width:120px;justify-content:flex-end">
        <div style="width:20px">A</div>
      </div>
    HTML

    space_around = build_layout(<<~HTML)
      <div style="display:flex;width:120px;justify-content:space-around">
        <div style="width:20px">A</div>
        <div style="width:20px">B</div>
      </div>
    HTML

    space_evenly = build_layout(<<~HTML)
      <div style="display:flex;width:120px;justify-content:space-evenly">
        <div style="width:20px">A</div>
        <div style="width:20px">B</div>
      </div>
    HTML

    space_between = build_layout(<<~HTML)
      <div style="display:flex;width:120px;justify-content:space-between">
        <div style="width:20px">A</div>
        <div style="width:20px">B</div>
      </div>
    HTML

    assert_in_delta 100, flex_end.children[0].x, 0.01
    assert_in_delta 20, space_around.children[0].x, 0.01
    assert_in_delta 80, space_around.children[1].x, 0.01
    assert_in_delta 26.67, space_evenly.children[0].x, 0.01
    assert_in_delta 73.33, space_evenly.children[1].x, 0.01
    assert_in_delta 0, space_between.children[0].x, 0.01
    assert_in_delta 100, space_between.children[1].x, 0.01
  end

  def test_align_items_flex_end
    tree = build_layout(<<~HTML)
      <div style="display:flex;width:100px;height:80px;align-items:flex-end">
        <div style="width:20px;height:30px">A</div>
      </div>
    HTML

    assert_in_delta 50, tree.children[0].y, 0.01
  end

  def test_column_grow_and_shrink
    grown = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:80px;height:100px">
        <div style="height:20px;flex-grow:1">A</div>
        <div style="height:20px;flex-grow:1">B</div>
      </div>
    HTML

    shrunk = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:80px;height:60px">
        <div style="height:50px">A</div>
        <div style="height:50px">B</div>
      </div>
    HTML

    assert_in_delta 50, grown.children[0].height, 0.01
    assert_in_delta 50, grown.children[1].height, 0.01
    assert_in_delta 30, shrunk.children[0].height, 0.01
    assert_in_delta 30, shrunk.children[1].height, 0.01
  end

  def test_column_reverse_and_alignment_variants
    flex_end = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column-reverse;width:100px;height:80px;align-items:flex-end;justify-content:flex-end">
        <div style="width:20px;height:20px">A</div>
        <div style="width:30px;height:20px">B</div>
      </div>
    HTML

    centered = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:100px;height:80px;align-items:center;justify-content:center">
        <div style="width:20px;height:20px">A</div>
      </div>
    HTML

    item_b = child_by_text(flex_end, "B")

    assert_in_delta 70, item_b.x, 0.01
    assert_in_delta 40, item_b.y, 0.01
    assert_in_delta 40, centered.children[0].x, 0.01
    assert_in_delta 30, centered.children[0].y, 0.01
  end

  def test_column_space_around_and_evenly
    space_around = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:80px;height:120px;justify-content:space-around">
        <div style="height:20px">A</div>
        <div style="height:20px">B</div>
      </div>
    HTML

    space_evenly = build_layout(<<~HTML)
      <div style="display:flex;flex-direction:column;width:80px;height:120px;justify-content:space-evenly">
        <div style="height:20px">A</div>
        <div style="height:20px">B</div>
      </div>
    HTML

    assert_in_delta 20, space_around.children[0].y, 0.01
    assert_in_delta 80, space_around.children[1].y, 0.01
    assert_in_delta 26.67, space_evenly.children[0].y, 0.01
    assert_in_delta 73.33, space_evenly.children[1].y, 0.01
  end

  def test_column_uses_intrinsic_width_when_not_stretched
    tree = build_layout(<<~HTML)
      <div style="display:inline-flex;flex-direction:column;align-items:flex-start">
        <div>Wide text</div>
      </div>
    HTML

    expected = SilkLayout::Render::FontLibrary.measure_text("Wide text", font_size: 16, font_family: "Helvetica")

    assert_in_delta expected, tree.children[0].width, 0.01
    assert_in_delta expected, tree.width, 0.01
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
    SilkLayout::Layout::Engine.layout(dom, rules, viewport_width: viewport_width).children.first
  end

  def text_content(box)
    return box.text if box.respond_to?(:text) && box.text

    box.children.map { |child| text_content(child) }.join
  end

  def child_by_text(box, text)
    box.children.find { |child| text_content(child) == text }
  end
end
