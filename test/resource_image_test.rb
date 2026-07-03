# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"

class ResourceImageTest < Minitest::Test
  PNG_FIXTURE = File.expand_path("fixtures/images/checker.png", __dir__)

  def test_load_reads_png_dimensions
    image = SilkLayout::Resource::Image.load(PNG_FIXTURE)

    assert_equal PNG_FIXTURE, image.path
    assert_equal 12, image.width
    assert_equal 8, image.height
    assert_in_delta 1.5, image.aspect_ratio
  end

  def test_load_reads_jpeg_dimensions
    Dir.mktmpdir do |dir|
      path = File.join(dir, "sample.jpg")
      File.binwrite(path, jpeg_bytes(width: 17, height: 11))

      image = SilkLayout::Resource::Image.load(path)

      assert_equal 17, image.width
      assert_equal 11, image.height
    end
  end

  def test_load_returns_nil_for_missing_or_unsupported_images
    Dir.mktmpdir do |dir|
      unsupported = File.join(dir, "image.gif")
      File.write(unsupported, "GIF89a")

      assert_nil SilkLayout::Resource::Image.load(File.join(dir, "missing.png"))
      assert_nil SilkLayout::Resource::Image.load(unsupported)
      assert_nil SilkLayout::Resource::Image.load("https://example.test/image.png")
    end
  end

  def test_load_returns_nil_for_invalid_uri
    assert_nil SilkLayout::Resource::Image.load("http://[bad")
  end

  def test_jpeg_reader_skips_non_dimension_segments
    Dir.mktmpdir do |dir|
      path = File.join(dir, "sample.jpg")
      File.binwrite(path, jpeg_bytes_with_app_segment(width: 19, height: 13))

      image = SilkLayout::Resource::Image.load(path)

      assert_equal 19, image.width
      assert_equal 13, image.height
    end
  end

  private

  def jpeg_bytes(width:, height:)
    [
      0xFF, 0xD8,
      0xFF, 0xC0,
      0x00, 0x0B,
      0x08,
      (height >> 8) & 0xFF,
      height & 0xFF,
      (width >> 8) & 0xFF,
      width & 0xFF,
      0x01,
      0x01,
      0x11,
      0x00,
      0xFF, 0xD9
    ].pack("C*")
  end

  def jpeg_bytes_with_app_segment(width:, height:)
    [
      0xFF, 0xD8,
      0xFF, 0xE0,
      0x00, 0x04,
      0x00, 0x00
    ].pack("C*") + jpeg_bytes(width: width, height: height).byteslice(2..)
  end
end
