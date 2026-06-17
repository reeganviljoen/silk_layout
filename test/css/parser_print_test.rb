# frozen_string_literal: true

require_relative "../test_helper"

class CSSParserPrintTest < Minitest::Test
  def test_print_target_applies_base_print_and_all_rules_but_ignores_screen_rules
    rules = SilkLayout::CSS::Parser.parse_all(
      [
        <<~CSS
          div { color: black; }
          @media print { div { color: red; } }
          @media all { div { display: block; } }
          @media screen { div { color: blue; display: none; } }
        CSS
      ],
      media: :print
    )

    assert_equal ["black", "red"], declaration_values(rules, "color")
    assert_equal ["block"], declaration_values(rules, "display")
  end

  def test_page_rules_resolve_a4_inside_print_media
    page_rules = SilkLayout::CSS::Parser.parse_page_rules(
      [
        <<~CSS
          @media screen { @page { size: 400px 500px; } }
          @media print { @page { size: A4 landscape; } }
        CSS
      ],
      media: :print
    )

    width, height = SilkLayout::CSS::PageRule.resolve_page_size(page_rules)

    assert_in_delta 1122.519, width, 0.001
    assert_in_delta 793.701, height, 0.001
  end

  def test_page_rules_resolve_explicit_px_and_in_dimensions
    page_rules = SilkLayout::CSS::Parser.parse_page_rules(["@page { size: 400px 5in; }"])

    assert_equal [400.0, 480.0], SilkLayout::CSS::PageRule.resolve_page_size(page_rules)
  end

  def test_page_rules_are_not_applied_for_screen_target
    page_rules = SilkLayout::CSS::Parser.parse_page_rules(["@page { size: A4; }"], media: :screen)

    assert_empty page_rules
  end

  private

  def declaration_values(rules, property)
    rules.flat_map do |rule|
      rule.declarations.filter_map do |name, declaration|
        declaration.value if name == property
      end
    end
  end
end
