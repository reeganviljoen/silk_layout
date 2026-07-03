# frozen_string_literal: true

require_relative "../test_helper"

class CssValuesTest < Minitest::Test
  def test_resolves_percentage_lengths
    assert_in_delta 120, SilkLayout::CSS::Values.resolve_length("50%", reference: 240), 0.01
  end

  def test_resolves_calc_with_percentage_and_px_terms
    assert_in_delta 280, SilkLayout::CSS::Values.resolve_length("calc(100% - 20px)", reference: 300), 0.01
  end

  def test_keeps_calc_expressions_together_when_splitting_tokens
    assert_equal ["calc(100% - 20px)", "10px"], SilkLayout::CSS::Values.split_tokens("calc(100% - 20px) 10px")
  end

  def test_expands_edge_values_with_calc_tokens
    assert_equal(
      {top: "calc(100% - 20px)", right: "5px", bottom: "calc(100% - 20px)", left: "5px"},
      SilkLayout::CSS::Values.expanded_edges("calc(100% - 20px) 5px")
    )
  end

  def test_named_and_invalid_lengths_resolve_safely
    assert_in_delta 3, SilkLayout::CSS::Values.resolve_length("medium"), 0.01
    assert_in_delta 0, SilkLayout::CSS::Values.resolve_length("not-a-length"), 0.01
  end

  def test_reference_relative_lengths_use_default_without_reference
    assert_in_delta 7, SilkLayout::CSS::Values.resolve_length("50%", default: 7), 0.01
    assert_in_delta 9, SilkLayout::CSS::Values.resolve_length("calc(50% + 2px)", default: 9), 0.01
  end

  def test_malformed_calc_falls_back_to_numeric_prefix
    assert_in_delta 0, SilkLayout::CSS::Values.resolve_length("calc(100% * 2)", reference: 200), 0.01
  end

  def test_unknown_length_type_resolves_to_default
    length = SilkLayout::CSS::Values::Length.new(:unknown)

    assert_equal 11, length.resolve(default: 11)
  end
end
