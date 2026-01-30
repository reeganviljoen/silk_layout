# frozen_string_literal: true

require "silk_layout"
require "ferrum"
require "chunky_png"
require "fileutils"
require "open3"
require "securerandom"
require "tmpdir"

module VisualHelpers
  VIEWPORT_WIDTH = 800
  VIEWPORT_HEIGHT = 1000
  VIEWPORT = [VIEWPORT_WIDTH, VIEWPORT_HEIGHT].freeze

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
    css = File.read(css_path)
    SilkLayout.render(html, css, out_pdf)
  end

  # ----------------------------
  # Browser rendering (Ferrum)
  # ----------------------------
  def render_browser(html_path, css_path, out_pdf)
    html = File.read(html_path)
    css = File.read(css_path)

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
              font-family: Helvetica;
              font-size: 16px;
              line-height: 1.2;
            }

            * {
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
      window_size: VIEWPORT,
      browser_path: ENV["BROWSER_PATH"] || ENV["CHROME_PATH"] || ENV["CHROME_BIN"],
      process_timeout: (ENV["FERRUM_PROCESS_TIMEOUT"] || 30).to_i,
      browser_options: {
        "no-sandbox" => nil,
        "disable-dev-shm-usage" => nil,
        "disable-gpu" => nil
      }
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
    begin
      File.delete(tmp_html)
    rescue
      nil
    end
  end

  # ----------------------------
  # PDF → PNG
  # ----------------------------
  def pdf_to_png(pdf_path, png_path)
    FileUtils.mkdir_p(File.dirname(png_path))

    unless File.exist?(pdf_path) && File.size(pdf_path).to_i > 0
      raise "PDF missing or empty: #{pdf_path}"
    end

    # 72 DPI is CRITICAL:
    # 1 CSS px = 1 pt at 96 DPI → convert down for pixel match
    magick_available = command_available?("magick")
    convert_available = command_available?("convert")
    pdftocairo_available = command_available?("pdftocairo")
    pdftoppm_available = command_available?("pdftoppm")
    sips_available = command_available?("sips")

    if pdftocairo_available
      out_base = png_path.delete_suffix(".png")
      ok, stderr = run_cmd(
        "pdftocairo",
        "-f",
        "1",
        "-l",
        "1",
        "-r",
        "72",
        "-png",
        "-singlefile",
        pdf_path,
        out_base
      )

      if ok
        return if File.exist?(png_path)

        alt_path = "#{out_base}-1.png"
        if File.exist?(alt_path)
          FileUtils.mv(alt_path, png_path)
          return
        end
      end

      @last_pdf_to_png_error = "pdftocairo: #{stderr}".strip
    end

    if pdftoppm_available
      out_base = png_path.delete_suffix(".png")
      ok, stderr = run_cmd(
        "pdftoppm",
        "-f", "1",
        "-l", "1",
        "-singlefile",
        "-r", "72",
        "-png",
        pdf_path,
        out_base
      )
      if ok
        return if File.exist?(png_path)

        alt_path = "#{out_base}-1.png"
        if File.exist?(alt_path)
          FileUtils.mv(alt_path, png_path)
          return
        end
      end

      @last_pdf_to_png_error = "pdftoppm: #{stderr}".strip
    end

    if magick_available
      ok, stderr = run_cmd(
        "magick",
        "-density", "72",
        "#{pdf_path}[0]",
        png_path
      )
      return if ok

      @last_pdf_to_png_error = "magick: #{stderr}".strip
    end

    if convert_available
      ok, stderr = run_cmd(
        "convert",
        "-density", "72",
        "#{pdf_path}[0]",
        png_path
      )
      return if ok

      @last_pdf_to_png_error = "convert: #{stderr}".strip
    end

    if sips_available
      ok, stderr = run_cmd(
        "sips",
        "-s", "format", "png",
        pdf_path,
        "--out", png_path
      )
      return if ok

      @last_pdf_to_png_error = "sips: #{stderr}".strip
    end

    if !pdftocairo_available && !pdftoppm_available && !magick_available && !convert_available && !sips_available
      raise "PDF to PNG conversion failed (no converters found in PATH)"
    end

    raise "PDF to PNG conversion failed (#{@last_pdf_to_png_error})"
  end

  def command_available?(name)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
      path = File.join(dir, name)
      File.file?(path) && File.executable?(path)
    end
  end

  def run_cmd(*args)
    stdout, stderr, status = Open3.capture3(*args)
    [status.success?, [stdout, stderr].reject(&:empty?).join("\n").strip]
  end

  # ----------------------------
  # Image diff
  # ----------------------------
  def image_diff(a_path, b_path)
    a = ChunkyPNG::Image.from_file(a_path)
    b = ChunkyPNG::Image.from_file(b_path)

    per_channel_tolerance = (ENV["PIXEL_TOLERANCE"] || 10).to_i

    downsample_factor = (ENV["DOWNSAMPLE"] || 2).to_i

    a = autocrop(a)
    b = autocrop(b)

    if downsample_factor > 1
      a = downsample(a, downsample_factor)
      b = downsample(b, downsample_factor)
    end

    # Crop both to smallest common area
    width = [a.width, b.width].min
    height = [a.height, b.height].min

    diff = 0
    height.times do |y|
      width.times do |x|
        pa = a[x, y]
        pb = b[x, y]

        next if pa == pb

        dr = (ChunkyPNG::Color.r(pa) - ChunkyPNG::Color.r(pb)).abs
        dg = (ChunkyPNG::Color.g(pa) - ChunkyPNG::Color.g(pb)).abs
        db = (ChunkyPNG::Color.b(pa) - ChunkyPNG::Color.b(pb)).abs
        da = (ChunkyPNG::Color.a(pa) - ChunkyPNG::Color.a(pb)).abs

        next if [dr, dg, db, da].max <= per_channel_tolerance

        diff += 1
      end
    end

    diff
  end

  def downsample(image, factor)
    w = image.width / factor
    h = image.height / factor
    return image if w <= 0 || h <= 0

    out = ChunkyPNG::Image.new(w, h, ChunkyPNG::Color::TRANSPARENT)

    h.times do |y|
      w.times do |x|
        r_sum = g_sum = b_sum = a_sum = 0
        count = 0

        (factor * y...(factor * y + factor)).each do |sy|
          (factor * x...(factor * x + factor)).each do |sx|
            px = image[sx, sy]
            r_sum += ChunkyPNG::Color.r(px)
            g_sum += ChunkyPNG::Color.g(px)
            b_sum += ChunkyPNG::Color.b(px)
            a_sum += ChunkyPNG::Color.a(px)
            count += 1
          end
        end

        out[x, y] = ChunkyPNG::Color.rgba(
          r_sum / count,
          g_sum / count,
          b_sum / count,
          a_sum / count
        )
      end
    end

    out
  end

  def autocrop(image)
    alpha_threshold = (ENV["ALPHA_THRESHOLD"] || 0).to_i

    min_x = image.width
    min_y = image.height
    max_x = -1
    max_y = -1

    image.height.times do |y|
      image.width.times do |x|
        next if ChunkyPNG::Color.a(image[x, y]) <= alpha_threshold

        min_x = x if x < min_x
        min_y = y if y < min_y
        max_x = x if x > max_x
        max_y = y if y > max_y
      end
    end

    return image if max_x == -1

    image.crop(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
  end
end
