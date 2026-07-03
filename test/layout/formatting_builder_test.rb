# frozen_string_literal: true

require_relative "../test_helper"

class FormattingBuilderTest < Minitest::Test
  def test_collapses_whitespace_only_text_between_inline_runs
    tree = build_tree("<p><span>Hello</span> \n <span>world</span></p>")

    assert_equal ["Hello", " ", "world"], text_boxes(tree).map(&:text)
  end

  def test_drops_indentation_whitespace_between_block_nodes
    tree = build_tree("<div>\n  <p>Hello</p>\n  <p>world</p>\n</div>")

    assert_equal ["Hello", "world"], text_boxes(tree).map(&:text)
  end

  def test_preserves_spaces_around_inline_elements
    tree = build_tree("<p>Hello <strong>world</strong> again</p>")

    assert_equal ["Hello ", "world", " again"], text_boxes(tree).map(&:text)
  end

  def test_unknown_display_falls_back_to_block_box
    tree = build_tree(%(<p><span>A</span><span style="display:contents">B</span></p>))
    paragraph = find_box(tree) { |box| box.node&.tag == "p" }

    assert_instance_of SilkLayout::Layout::AnonymousBlockBox, paragraph.children.first
    assert_instance_of SilkLayout::Layout::BlockBox, paragraph.children.last
    assert_equal "contents", paragraph.children.last.display
  end

  def test_image_dimensions_can_fall_back_to_html_aspect_ratio
    tree = build_tree(%(<img src="missing.png" width="20" height="10">))
    image = find_box(tree) { |box| box.respond_to?(:replaced?) && box.replaced? }

    assert_nil image.image_resource
    assert_in_delta 20, image.width, 0.01
    assert_in_delta 10, image.height, 0.01
    assert_match %r{/missing\.png\z}, image.image_source
  end

  def test_flex_flow_sets_direction_and_wrap_from_shorthand
    tree = build_tree(%(<div style="display:flex;flex-flow:row-reverse wrap-reverse"></div>))
    flex = find_box(tree) { |box| box.is_a?(SilkLayout::Layout::FlexBox) }

    assert_equal "row-reverse", flex.flex[:direction]
    assert_equal "wrap-reverse", flex.flex[:wrap]
  end

  def test_background_shorthand_accepts_named_color_tokens
    tree = build_tree(%(<div style="background:rebeccapurple"></div>))
    div = find_box(tree) { |box| box.node&.tag == "div" }

    assert_equal :rebeccapurple, div.background_color
  end

  private

  def build_tree(body)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{body}
        </body>
      </html>
    HTML

    dom, = SilkLayout::HTML::Parser.parse_document(html)
    SilkLayout::CSS::Cascade.apply(dom, [])
    SilkLayout::Layout::FormattingBuilder.build(dom)
  end

  def text_boxes(box, acc = [])
    return acc unless box

    acc << box if box.is_a?(SilkLayout::Layout::TextBox)
    box.children.each { |child| text_boxes(child, acc) }
    acc
  end

  def find_box(box, &block)
    return box if block.call(box)

    box.children.each do |child|
      found = find_box(child, &block)
      return found if found
    end

    nil
  end
end
