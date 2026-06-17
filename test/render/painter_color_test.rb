# frozen_string_literal: true

require_relative "../test_helper"

class PainterColorTest < Minitest::Test
  def test_converts_colors_through_shared_parser
    assert_equal [255, 0, 0], SilkLayout::Render::Painter.rgb_color(:red)
    assert_equal [17, 34, 51], SilkLayout::Render::Painter.rgb_color(:"#123")
    assert_equal [10, 20, 30], SilkLayout::Render::Painter.rgb_color(:"rgb(10, 20, 30)")
    assert_equal [0, 128, 0], SilkLayout::Render::Painter.rgb_color(:"hsl(120, 100%, 25%)")
  end

  def test_transparent_and_invalid_colors_do_not_convert_to_rgb
    assert_nil SilkLayout::Render::Painter.rgb_color(:transparent)
    assert_nil SilkLayout::Render::Painter.rgb_color(:unknown)
  end
end
