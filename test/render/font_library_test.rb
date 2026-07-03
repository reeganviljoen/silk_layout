# frozen_string_literal: true

require_relative "../test_helper"

class FontLibraryTest < Minitest::Test
  def test_resolves_family_aliases_weight_and_style
    assert_equal(
      "Times-BoldItalic",
      SilkLayout::Render::FontLibrary.resolve_font_name(
        "'Times New Roman', serif",
        font_weight: "700",
        font_style: "italic"
      )
    )
  end

  def test_unknown_family_and_normal_weight_fall_back_to_helvetica
    assert_equal(
      "Helvetica",
      SilkLayout::Render::FontLibrary.resolve_font_name(
        "Unknown Family",
        font_weight: "normal",
        font_style: "normal"
      )
    )
  end

  def test_empty_text_measures_as_zero
    assert_equal 0, SilkLayout::Render::FontLibrary.measure_text("", font_size: 12, font_family: "Helvetica")
  end
end
