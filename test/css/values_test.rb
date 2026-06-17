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
end
