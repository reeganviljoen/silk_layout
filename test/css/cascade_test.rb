# frozen_string_literal: true

require "test_helper"

class CSSCascadeTest < Minitest::Test
  def style_for(html, css, property)
    dom = SilkLayout::HTML::Parser.parse(html)
    rules = SilkLayout::CSS::Parser.parse_all([css])
    SilkLayout::CSS::Cascade.apply(dom, rules)

    target = find_first_element(dom)
    target.computed_style[property]
  end

  def find_first_element(node)
    return node if node.element? && content_element?(node)

    node.children.each do |child|
      found = find_first_element(child)
      return found if found
    end

    nil
  end

  def content_element?(node)
    !%w[html body head].include?(node.tag)
  end

  def test_element_selector
    value = style_for("<p>Hello</p>", "p { color: red }", "color")
    assert_equal "red", value
  end

  def test_class_selector
    value = style_for(
      "<p class='note'>Hi</p>",
      ".note { color: blue }",
      "color"
    )

    assert_equal "blue", value
  end

  def test_id_wins_over_element
    value = style_for(
      "<p id='x'>Hi</p>",
      "p { color: red } #x { color: green }",
      "color"
    )

    assert_equal "green", value
  end
end
