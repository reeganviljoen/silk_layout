
# frozen_string_literal: true

require "silk_layout"
require "ferrum"
require "chunky_png"
require "fileutils"
require "securerandom"
require "tmpdir"

module VisualHelpers
  VIEWPORT_WIDTH  = 800
  VIEWPORT_HEIGHT = 1000
  VIEWPORT        = [VIEWPORT_WIDTH, VIEWPORT_HEIGHT].freeze

  TMP_DIR = "tmp/visual"

  def setup
    FileUtils.mkdir_p(TMP_DIR)
  end

  # ----------------------------
  # SilkLayout rendering
  # ----------------------------
  def render_silk(html_path, css_path, out_pdf)
    FileUtils.mkdir_p(File.dirname(out_pdf))

    html = File.read(html_path)
    css  = File.read(css_path)
    binding.irb if html == ''
    SilkLayout.render(html, css, out_pdf)
  end

  # ----------------------------
  # Browser rendering (Ferrum)
  # ----------------------------
  def render_browser(html_path, css_path, out_pdf)
    html = File.read(html_path)
    css  = File.read(css_path)

    tmp_html = File.join(Dir.tmpdir, "#{SecureRandom.hex}.html")

    File.write(tmp_html, <<~HTML)
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <style>
            @page {
              size: #{VIEWPORT_WIDTH}px #{VIEWPORT_HEIGHT}px;
              margin: 0;
            }

            html, body {
              width: #{VIEWPORT_WIDTH}px;
              height: #{VIEWPORT_HEIGHT}px;
              margin: 0;
              padding: 0;
            }

            #{css}
          </style>
        </head>
        <body>
          #{html}
        </body>
      </html>
    HTML

    browser = Ferrum::Browser.new(
      headless: true,
      window_size: VIEWPORT
    )

    page = browser.create_page
    page.go_to("file://#{tmp_html}")

    # IMPORTANT:
    # Ferrum expects inches for paper size.
    # CSS pixels → inches at 96 DPI
    page.pdf(
      path: out_pdf,
      print_background: true,
      prefer_css_page_size: true,
      margin_top: 0,
      margin_bottom: 0,
      margin_left: 0,
      margin_right: 0
    )

    browser.quit
    File.delete(tmp_html) rescue nil
  end

  # ----------------------------
  # PDF → PNG
  # ----------------------------
  def pdf_to_png(pdf_path, png_path)
    FileUtils.mkdir_p(File.dirname(png_path))

    # 72 DPI is CRITICAL:
    # 1 CSS px = 1 pt at 96 DPI → convert down for pixel match
    system(
      "magick",
      "-density", "72",
      pdf_path,
      png_path
    ) or raise "ImageMagick convert failed"
  end

  # ----------------------------
  # Image diff
  # ----------------------------
  def image_diff(a_path, b_path)
    a = ChunkyPNG::Image.from_file(a_path)
    b = ChunkyPNG::Image.from_file(b_path)

    # Crop both to smallest common area
    width  = [a.width, b.width].min
    height = [a.height, b.height].min

    diff = 0
    height.times do |y|
      width.times do |x|
        diff += 1 unless a[x, y] == b[x, y]
      end
    end

    diff
  end
end

