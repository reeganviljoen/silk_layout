# frozen_string_literal: true

require_relative "../test_helper"

class CssSelectorTest < Minitest::Test
  def test_universal_and_attribute_selectors
    body = <<~HTML
      <div id="target" data-active data-role="primary"></div>
      <div id="other" data-role="secondary"></div>
    HTML

    dom = cascade(<<~CSS, body)
      * { color: blue; }
      [data-active] { font-size: 20px; }
      [data-role="primary"] { font-family: Courier; }
    CSS

    target = find_by_id(dom, "target").computed_style
    other = find_by_id(dom, "other").computed_style

    assert_equal "blue", target["color"]
    assert_equal "20px", target["font-size"]
    assert_equal "Courier", target["font-family"]
    assert_equal "blue", other["color"]
    assert_equal "16px", other["font-size"]
  end

  def test_adjacent_sibling_child_position_and_not_selectors
    body = <<~HTML
      <section>
        <div id="first" class="item"></div>
        <div class="lead"></div>
        <div id="target" class="item target"></div>
        <div id="skip" class="item skip"></div>
        <div id="last" class="item"></div>
      </section>
    HTML

    dom = cascade(<<~CSS, body)
      .item:first-child { color: red; }
      .item:last-child { font-size: 30px; }
      .lead + .target { font-family: Courier; }
      .item:not(.skip) { font-weight: bold; }
      .item:not([hidden]) { font-style: italic; }
    CSS

    first = find_by_id(dom, "first").computed_style
    target = find_by_id(dom, "target").computed_style
    skip = find_by_id(dom, "skip").computed_style
    last = find_by_id(dom, "last").computed_style

    assert_equal "red", first["color"]
    assert_equal "Courier", target["font-family"]
    assert_equal "bold", target["font-weight"]
    assert_equal "normal", skip["font-weight"]
    assert_equal "italic", target["font-style"]
    assert_equal "30px", last["font-size"]
  end

  def test_unsupported_selectors_fail_closed
    body = <<~HTML
      <section>
        <div id="first"></div>
        <div id="target" data-role="primary"></div>
      </section>
    HTML

    dom = cascade(<<~CSS, body)
      #target:nth-child(2) { color: red; }
      #target[data-role^="pri"] { font-size: 30px; }
      #first ~ #target { font-family: Courier; }
      #target::before { font-weight: bold; }
    CSS

    target = find_by_id(dom, "target").computed_style

    assert_equal "black", target["color"]
    assert_equal "16px", target["font-size"]
    assert_equal "Helvetica", target["font-family"]
    assert_equal "normal", target["font-weight"]
  end

  private

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
