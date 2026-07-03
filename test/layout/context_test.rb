# frozen_string_literal: true

require_relative "../test_helper"

class ContextTest < Minitest::Test
  def test_viewport_width_aliases_width
    context = SilkLayout::Layout::Context.new(width: 640, page_size: {width: 640, height: 480})

    assert_equal 640, context.width
    assert_equal 640, context.viewport_width
    assert_equal({width: 640, height: 480}, context.page_size)
  end
end
