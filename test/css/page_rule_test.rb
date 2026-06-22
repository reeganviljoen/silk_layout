# frozen_string_literal: true

require_relative "../test_helper"

class CSSPageRuleTest < Minitest::Test
  def test_parse_size_returns_nil_for_empty_invalid_or_non_positive_values
    assert_nil SilkLayout::CSS::PageRule.parse_size(nil)
    assert_nil SilkLayout::CSS::PageRule.parse_size("")
    assert_nil SilkLayout::CSS::PageRule.parse_size("screen")
    assert_nil SilkLayout::CSS::PageRule.parse_size("0px")
    assert_nil SilkLayout::CSS::PageRule.parse_size("-1in")
    assert_nil SilkLayout::CSS::PageRule.parse_size("10em")
    assert_nil SilkLayout::CSS::PageRule.parse_size("10px 20px 30px")
  end

  def test_parse_size_supports_square_lengths_and_orientation
    assert_equal [300.0, 300.0], SilkLayout::CSS::PageRule.parse_size("300px")
    assert_equal [480.0, 288.0], SilkLayout::CSS::PageRule.parse_size("3in 5in landscape")
    assert_equal [288.0, 480.0], SilkLayout::CSS::PageRule.parse_size("5in 3in portrait")
  end

  def test_parse_size_supports_named_a4_portrait_and_landscape
    portrait = SilkLayout::CSS::PageRule.parse_size("A4 portrait")
    landscape = SilkLayout::CSS::PageRule.parse_size("A4 landscape")

    assert_operator portrait[0], :<, portrait[1]
    assert_operator landscape[0], :>, landscape[1]
  end

  def test_resolve_page_size_uses_last_unnamed_page_rule_with_size
    rules = [
      SilkLayout::CSS::PageRule.new(
        selector: "",
        declarations: [["size", declaration("200px 300px")]],
        order: 2
      ),
      SilkLayout::CSS::PageRule.new(
        selector: ":first",
        declarations: [["size", declaration("100px 100px")]],
        order: 3
      ),
      SilkLayout::CSS::PageRule.new(
        selector: "",
        declarations: [["margin", declaration("1in")]],
        order: 4
      ),
      SilkLayout::CSS::PageRule.new(
        selector: "",
        declarations: [["size", declaration("400px 500px")]],
        order: 5
      )
    ]

    assert_equal [400.0, 500.0], SilkLayout::CSS::PageRule.resolve_page_size(rules)
  end

  def test_resolve_page_size_returns_nil_without_matching_size
    rules = [
      SilkLayout::CSS::PageRule.new(
        selector: ":left",
        declarations: [["size", declaration("200px 300px")]],
        order: 1
      ),
      SilkLayout::CSS::PageRule.new(
        selector: "",
        declarations: [["margin", declaration("1in")]],
        order: 2
      )
    ]

    assert_nil SilkLayout::CSS::PageRule.resolve_page_size(rules)
  end

  private

  def declaration(value)
    SilkLayout::CSS::Declaration.new(value: value)
  end
end
