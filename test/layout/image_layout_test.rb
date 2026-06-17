# frozen_string_literal: true

require_relative "../test_helper"
require "fileutils"
require "tmpdir"

class ImageLayoutTest < Minitest::Test
  FIXTURE_HTML = File.expand_path("../fixtures/local_image.html", __dir__)

  def test_local_image_uses_intrinsic_dimensions
    image = image_for(%(<img src="images/checker.png" alt="checker">))

    assert image.replaced?
    assert image.image?
    assert_equal 12, image.intrinsic_width
    assert_equal 8, image.intrinsic_height
    assert_in_delta 12, image.content_box_width
    assert_in_delta 8, image.content_box_height
    assert_match %r{/test/fixtures/images/checker\.png\z}, image.image_path
  end

  def test_width_attribute_preserves_intrinsic_aspect_ratio
    image = image_for(%(<img src="images/checker.png" width="24" alt="checker">))

    assert_in_delta 24, image.content_box_width
    assert_in_delta 16, image.content_box_height
  end

  def test_css_width_overrides_width_attribute_and_preserves_intrinsic_aspect_ratio
    image = image_for(%(<img src="images/checker.png" width="99" style="width: 24px" alt="checker">))

    assert_in_delta 24, image.content_box_width
    assert_in_delta 16, image.content_box_height
  end

  def test_css_height_preserves_intrinsic_aspect_ratio
    image = image_for(%(<img src="images/checker.png" style="height: 4px" alt="checker">))

    assert_in_delta 6, image.content_box_width
    assert_in_delta 4, image.content_box_height
  end

  def test_pdf_smoke_renders_local_image
    Dir.mktmpdir do |dir|
      out = File.join(dir, "local_image.pdf")

      SilkLayout.render_document(File.read(FIXTURE_HTML), out, url: FIXTURE_HTML)

      assert File.size?(out), "expected a non-empty PDF"
    end
  end

  private

  def image_for(fragment)
    root = layout_fragment(fragment)
    images = image_boxes(root)

    assert_equal 1, images.length
    images.first
  end

  def layout_fragment(fragment)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          #{fragment}
        </body>
      </html>
    HTML

    dom, stylesheets = SilkLayout::HTML::Parser.parse_document(html, url: FIXTURE_HTML)
    rules = SilkLayout::CSS::Parser.parse_all(stylesheets)

    SilkLayout::Layout::Engine.layout(dom, rules)
  end

  def image_boxes(box, acc = [])
    return acc unless box

    acc << box if box.respond_to?(:replaced?) && box.replaced?
    box.children.each { |child| image_boxes(child, acc) }
    acc
  end
end
