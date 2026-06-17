# frozen_string_literal: true

require_relative "../test_helper"

class CssCascadeTest < Minitest::Test
  def test_longhand_after_shorthand_wins_within_rule
    style = computed_style(<<~CSS)
      .box {
        margin: 10px;
        margin-left: 3px;
      }
    CSS

    assert_equal "10px", style["margin-top"]
    assert_equal "10px", style["margin-right"]
    assert_equal "10px", style["margin-bottom"]
    assert_equal "3px", style["margin-left"]
  end

  def test_shorthand_after_longhand_wins_within_rule
    style = computed_style(<<~CSS)
      .box {
        padding-left: 3px;
        padding: 8px;
      }
    CSS

    assert_equal "8px", style["padding-top"]
    assert_equal "8px", style["padding-right"]
    assert_equal "8px", style["padding-bottom"]
    assert_equal "8px", style["padding-left"]
  end

  def test_important_longhand_beats_later_normal_shorthand
    style = computed_style(<<~CSS)
      .box {
        margin-left: 3px !important;
        margin: 10px;
      }
    CSS

    assert_equal "10px", style["margin-top"]
    assert_equal "3px", style["margin-left"]
  end

  def test_important_shorthand_beats_later_normal_longhand
    style = computed_style(<<~CSS)
      .box {
        border: 2px solid red !important;
        border-left-color: blue;
      }
    CSS

    assert_equal "red", style["border-left-color"]
    assert_equal "2px", style["border-left-width"]
    assert_equal "solid", style["border-left-style"]
  end

  def test_css_wide_keywords_resolve_for_known_properties
    body = <<~HTML
      <div id="parent">
        <div id="inherit-color"></div>
        <div id="initial-color"></div>
        <div id="unset-color"></div>
        <div id="inherit-margin"></div>
        <div id="unset-margin"></div>
        <div id="display-initial"></div>
      </div>
    HTML

    dom = cascade(<<~CSS, body)
      #parent {
        color: green;
        font-size: 22px;
        margin-left: 9px;
      }

      #inherit-color { color: inherit; }
      #initial-color { color: initial; }
      #unset-color {
        color: unset;
        font-size: unset;
      }
      #inherit-margin { margin-left: inherit; }
      #unset-margin { margin-left: unset; }
      #display-initial { display: initial; }
    CSS

    assert_equal "green", find_by_id(dom, "inherit-color").computed_style["color"]
    assert_equal "black", find_by_id(dom, "initial-color").computed_style["color"]
    assert_equal "green", find_by_id(dom, "unset-color").computed_style["color"]
    assert_equal "22px", find_by_id(dom, "unset-color").computed_style["font-size"]
    assert_equal "9px", find_by_id(dom, "inherit-margin").computed_style["margin-left"]
    assert_equal "0", find_by_id(dom, "unset-margin").computed_style["margin-left"]

    display_style = find_by_id(dom, "display-initial").computed_style
    assert_equal "inline", display_style["display"]
    assert display_style.explicit_display?
  end

  private

  def computed_style(css)
    find_by_id(cascade(css, "<div id=\"target\" class=\"box\"></div>"), "target").computed_style
  end

  def cascade(css, body)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            #{css}
          </style>
        </head>
        <body>
          #{body}
        </body>
      </html>
    HTML

    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html)
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)
    SilkLayout::CSS::Cascade.apply(dom, rules)
    dom
  end

  def find_by_id(node, id)
    return node if node.element? && node.attributes["id"] == id

    node.children.each do |child|
      found = find_by_id(child, id)
      return found if found
    end

    nil
  end
end
