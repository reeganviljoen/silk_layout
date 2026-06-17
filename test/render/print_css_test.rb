# frozen_string_literal: true

require_relative "../test_helper"
require "fileutils"
require "hexapdf"
require "securerandom"
require "tmpdir"

class PrintCSSTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("silk_layout_print_css")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if @tmpdir
  end

  def test_render_document_uses_page_size_from_page_rule
    path = render_pdf(<<~HTML)
      <style>
        @page { size: 4in 5in; }
      </style>
      <div>Hello</div>
    HTML

    assert_media_box(path, width: 288, height: 360)
  end

  def test_explicit_page_options_override_page_rule
    path = render_pdf(
      <<~HTML,
        <style>
          @page { size: A4; }
        </style>
        <div>Hello</div>
      HTML
      page_width: 400,
      page_height: 300
    )

    assert_media_box(path, width: 300, height: 225)
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
end
