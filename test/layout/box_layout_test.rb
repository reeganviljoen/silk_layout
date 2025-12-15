# frozen_string_literal: true

require "test_helper"

class BoxLayoutTest < Minitest::Test
  def test_block_boxes_stack_vertically
    html = "<div><p>One</p><p>Two</p></div>"
    doc = SilkLayout::Document.new(html: html)

    root_box = doc.layout
    body_box = root_box.children.first
    div_box = body_box.children.first

    first = div_box.children[0]
    second = div_box.children[1]

    assert_equal 0, first.y
    assert_equal first.height, second.y
  end

  def test_leaf_box_has_height
    html = "<p>Hello</p>"
    doc = SilkLayout::Document.new(html: html)

    root_box = doc.layout
    p_box = root_box.children.first

    assert p_box.height.positive?
  end
end
