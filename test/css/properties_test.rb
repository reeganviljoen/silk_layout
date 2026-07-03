# frozen_string_literal: true

require_relative "../test_helper"

class CSSPropertiesTest < Minitest::Test
  def test_css_wide_expansion_covers_supported_shorthands
    assert_expands_to ["margin-left", "inherit"], "margin", "inherit"
    assert_expands_to ["padding-top", "unset"], "padding", "unset"
    assert_expands_to ["border-left-style", "initial"], "border", "initial"
    assert_expands_to ["border-right-width", "inherit"], "border-width", "inherit"
    assert_expands_to ["border-bottom-color", "unset"], "border-bottom", "unset"
    assert_expands_to ["background-color", "initial"], "background", "initial"
    assert_expands_to ["flex-grow", "inherit"], "flex", "inherit"
    assert_expands_to ["flex-wrap", "unset"], "flex-flow", "unset"
    assert_expands_to ["row-gap", "initial"], "gap", "initial"
  end

  def test_regular_shorthand_expansion_covers_border_background_flex_and_gap
    border = SilkLayout::CSS::Properties.expand_declaration("border-top", "2px solid red")
    assert_includes border, ["border-top-width", "2px"]
    assert_includes border, ["border-top-style", "solid"]
    assert_includes border, ["border-top-color", "red"]

    border_color = SilkLayout::CSS::Properties.expand_declaration("border-color", "red green blue black")
    assert_includes border_color, ["border-right-color", "green"]

    background = SilkLayout::CSS::Properties.expand_declaration("background", "url(card.png) hsl(120, 100%, 25%)")
    assert_includes background, ["background-color", "hsl(120, 100%, 25%)"]

    flex_none = SilkLayout::CSS::Properties.expand_declaration("flex", "none")
    assert_includes flex_none, ["flex-grow", "0"]
    assert_includes flex_none, ["flex-shrink", "0"]
    assert_includes flex_none, ["flex-basis", "auto"]

    flex_auto = SilkLayout::CSS::Properties.expand_declaration("flex", "auto")
    assert_includes flex_auto, ["flex-grow", "1"]
    assert_includes flex_auto, ["flex-basis", "auto"]

    flex_flow = SilkLayout::CSS::Properties.expand_declaration("flex-flow", "column wrap")
    assert_includes flex_flow, ["flex-direction", "column"]
    assert_includes flex_flow, ["flex-wrap", "wrap"]

    gap = SilkLayout::CSS::Properties.expand_declaration("gap", "8px 12px")
    assert_includes gap, ["row-gap", "8px"]
    assert_includes gap, ["column-gap", "12px"]
  end

  def test_edge_values_and_color_tokens_cover_empty_and_fallback_paths
    assert_equal(
      {"top" => nil, "right" => nil, "bottom" => nil, "left" => nil},
      SilkLayout::CSS::Properties.edge_values("")
    )

    assert SilkLayout::CSS::Properties.color_token?("mysterycolor")
    refute SilkLayout::CSS::Properties.color_token?("")
    refute SilkLayout::CSS::Properties.color_token?("none")
    refute SilkLayout::CSS::Properties.color_token?("2px")
    refute SilkLayout::CSS::Properties.color_token?("solid")
    refute SilkLayout::CSS::Properties.color_token?("url(image.png)")
  end

  private

  def assert_expands_to(expected, property, value)
    assert_includes SilkLayout::CSS::Properties.expand_declaration(property, value), expected
  end
end
