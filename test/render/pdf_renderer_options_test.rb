# frozen_string_literal: true

require_relative "../test_helper"
require "fileutils"
require "hexapdf"
require "securerandom"
require "tmpdir"

class PdfRendererOptionsTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("silk_layout_render_options")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if @tmpdir
  end

  def test_render_document_default_page_size_still_writes_a_pdf
    path = render_pdf("<div>Hello</div>")

    assert_operator File.size(path), :>, 0
    assert_media_box(path, width: 600, height: 750)
  end

  def test_render_document_honors_page_dimensions
    path = render_pdf("<div>Hello</div>", page_width: 400, page_height: 300)

    assert_media_box(path, width: 300, height: 225)
  end

  def test_render_document_honors_page_size_array
    path = render_pdf("<div>Hello</div>", page_size: [500, 700])

    assert_media_box(path, width: 375, height: 525)
  end

  def test_render_document_honors_page_size_hash
    path = render_pdf("<div>Hello</div>", page_size: {width: 360, height: 480})

    assert_media_box(path, width: 270, height: 360)
  end

  def test_page_dimensions_override_css_page_size_for_layout
    path = render_pdf(
      <<~HTML,
        <style>
          @page { size: 8in 10in; }
        </style>
        <div style="background:red">Hello</div>
      HTML
      page_width: 320,
      page_height: 400
    )

    assert_media_box(path, width: 240, height: 300)
    assert_match(/0\.0 [0-9.]+ 240\.0 [0-9.]+ re/, page_contents(path))
  end

  def test_partial_page_dimensions_use_defaults_for_unspecified_axis
    path = render_pdf("<div>Hello</div>", page_height: 300)

    assert_media_box(path, width: 600, height: 225)
  end

  def test_render_document_honors_viewport_width
    path = render_pdf(
      %(<div style="background:red">Hello</div>),
      viewport_width: 320
    )

    assert_match(/0\.0 [0-9.]+ 240\.0 [0-9.]+ re/, page_contents(path))
  end

  def test_invalid_page_size_type_is_rejected
    error = assert_raises(ArgumentError) do
      SilkLayout::Render::PdfRenderer.render(empty_box, File.join(@tmpdir, "bad.pdf"), page_size: :letter)
    end

    assert_equal "page_size must be an Array or Hash", error.message
  end

  def test_invalid_page_dimensions_are_rejected
    error = assert_raises(ArgumentError) do
      SilkLayout::Render::PdfRenderer.render(empty_box, File.join(@tmpdir, "bad.pdf"), page_width: 0)
    end

    assert_equal "page_width must be a positive number of CSS pixels", error.message
  end

  private

  def render_pdf(html, **options)
    path = File.join(@tmpdir, "#{SecureRandom.hex}.pdf")
    SilkLayout.render_document(html, path, **options)
    path
  end

  def assert_media_box(path, width:, height:)
    box = HexaPDF::Document.open(path).pages[0].box(:media)

    assert_in_delta width, box.width, 0.001
    assert_in_delta height, box.height, 0.001
  end

  def page_contents(path)
    HexaPDF::Document.open(path).pages[0].contents
  end

  def empty_box
    SilkLayout::Layout::BlockBox.new(nil)
  end
end
