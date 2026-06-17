# frozen_string_literal: true

require_relative "../test_helper"

class CSSColorTest < Minitest::Test
  def test_parse_returns_existing_color
    color = SilkLayout::CSS::Color.parse("red")

    assert_same color, SilkLayout::CSS::Color.parse(color)
  end

  def test_parses_short_hex
    color = SilkLayout::CSS::Color.parse("#0f8")

    assert_equal [0, 255, 136], color.rgb
    assert_equal :"#0f8", color.to_sym
  end

  def test_parses_long_hex
    color = SilkLayout::CSS::Color.parse("#336699")

    assert_equal [51, 102, 153], color.rgb
    assert_equal :"#336699", color.to_sym
  end

  def test_parses_named_colors
    assert_equal [255, 0, 0], SilkLayout::CSS::Color.parse("red").rgb
    assert_equal [173, 216, 230], SilkLayout::CSS::Color.parse("lightblue").rgb
    assert_equal [102, 51, 153], SilkLayout::CSS::Color.parse("rebeccapurple").rgb
    assert_equal "red", SilkLayout::CSS::Color.parse(:red).to_s
  end

  def test_parses_rgb_function
    color = SilkLayout::CSS::Color.parse("rgb(10, 20, 30)")

    assert_equal [10, 20, 30], color.rgb
    assert_equal :"rgb(10, 20, 30)", color.to_sym
  end

  def test_parses_rgb_percentages
    color = SilkLayout::CSS::Color.parse("rgb(100% 50% 0%)")

    assert_equal [255, 128, 0], color.rgb
  end

  def test_parses_comma_rgb_with_slash_alpha
    color = SilkLayout::CSS::Color.parse("rgb(10, 20, 30 / 50%)")

    assert_equal [10, 20, 30], color.rgb
    assert_in_delta 0.5, color.alpha
  end

  def test_parses_rgba_function_and_keeps_alpha
    color = SilkLayout::CSS::Color.parse("rgba(10, 20, 30, 0.25)")

    assert_equal [10, 20, 30], color.rgb
    assert_in_delta 0.25, color.alpha
    assert_equal [10, 20, 30], SilkLayout::CSS::Color.rgb(color)
  end

  def test_treats_fully_transparent_rgba_as_unpaintable_rgb
    color = SilkLayout::CSS::Color.parse("rgba(10 20 30 / 0%)")

    assert_equal [10, 20, 30], color.rgb
    assert_predicate color, :transparent?
    assert_nil SilkLayout::CSS::Color.rgb(color)
  end

  def test_parses_hsl_function
    color = SilkLayout::CSS::Color.parse("hsl(120, 100%, 25%)")

    assert_equal [0, 128, 0], color.rgb
  end

  def test_parses_hsl_with_hue_units_and_alpha
    assert_equal [0, 255, 255], SilkLayout::CSS::Color.parse("hsl(0.5turn 100% 50% / 50%)").rgb
    assert_equal [0, 0, 255], SilkLayout::CSS::Color.parse("hsl(240deg 100% 50%)").rgb
    assert_equal [0, 255, 255], SilkLayout::CSS::Color.parse("hsl(3.141592653589793rad 100% 50%)").rgb
    assert_in_delta 0.5, SilkLayout::CSS::Color.parse("hsl(0.5turn 100% 50% / 50%)").alpha
  end

  def test_parses_hsl_color_wheel_segments
    assert_equal [255, 0, 0], SilkLayout::CSS::Color.parse("hsl(0 100% 50%)").rgb
    assert_equal [255, 255, 0], SilkLayout::CSS::Color.parse("hsl(60 100% 50%)").rgb
    assert_equal [0, 255, 0], SilkLayout::CSS::Color.parse("hsl(120 100% 50%)").rgb
    assert_equal [0, 255, 255], SilkLayout::CSS::Color.parse("hsl(180 100% 50%)").rgb
    assert_equal [0, 0, 255], SilkLayout::CSS::Color.parse("hsl(240 100% 50%)").rgb
    assert_equal [255, 0, 255], SilkLayout::CSS::Color.parse("hsl(300 100% 50%)").rgb
  end

  def test_parses_transparent
    color = SilkLayout::CSS::Color.parse("transparent")

    assert_equal [0, 0, 0], color.rgb
    assert_predicate color, :transparent?
    assert_nil SilkLayout::CSS::Color.rgb("transparent")
  end

  def test_rejects_invalid_colors
    assert_nil SilkLayout::CSS::Color.parse(nil)
    assert_nil SilkLayout::CSS::Color.parse("not-a-real-color")
    assert_nil SilkLayout::CSS::Color.parse("#12")
    assert_nil SilkLayout::CSS::Color.parse("rgb()")
    assert_nil SilkLayout::CSS::Color.parse("rgba(1, 2, 3)")
    assert_nil SilkLayout::CSS::Color.parse("rgb(1, nope, 3)")
    assert_nil SilkLayout::CSS::Color.parse("rgba(1, 2, 3, nope)")
    assert_nil SilkLayout::CSS::Color.parse("hsla(10, 20%, 30%)")
    assert_nil SilkLayout::CSS::Color.parse("hsl(10, 20, 30)")
    assert_nil SilkLayout::CSS::Color.rgb(nil)
  end
end
