# frozen_string_literal: true

require_relative "test_helper"
require_relative "support/visual_helpers"
require "webrick"

class VisualRegressionTest < Minitest::Test
  include VisualHelpers

  TMP_DIR = VisualHelpers::TMP_DIR
  TOLERANCE = (ENV["VISUAL_TOLERANCE"] || 500).to_i

  def setup
    super
    FileUtils.mkdir_p(TMP_DIR)
  end

  Dir["test/visual/*"].sort.each do |scenario|
    next unless File.directory?(scenario)

    name = File.basename(scenario)

    define_method("test_visual_#{name}") do
      html = File.join(scenario, "input.html")

      unless File.exist?(html)
        flunk "Missing input.html in #{scenario}"
      end

      silk_pdf = "#{TMP_DIR}/#{name}_silk.pdf"
      browser_pdf = "#{TMP_DIR}/#{name}_browser.pdf"
      silk_png = "#{TMP_DIR}/#{name}_silk.png"
      browser_png = "#{TMP_DIR}/#{name}_browser.png"

      if name == "remote_stylesheet"
        server = WEBrick::HTTPServer.new(
          Port: 0,
          BindAddress: "127.0.0.1",
          Logger: WEBrick::Log.new(File::NULL),
          AccessLog: []
        )

        server.mount_proc "/input.html" do |_req, res|
          res.status = 200
          res["Content-Type"] = "text/html"
          res.body = File.read(html)
        end

        server.mount_proc "/remote.css" do |_req, res|
          res.status = 200
          res["Content-Type"] = "text/css"
          res.body = File.read(File.join(scenario, "remote.css"))
        end

        thread = Thread.new { server.start }
        thread.abort_on_exception = true

        base_url = "http://127.0.0.1:#{server.config[:Port]}/"
        doc_url = "#{base_url}input.html"

        render_silk_document(File.read(html), silk_pdf, url: doc_url)
        render_browser_url(doc_url, browser_pdf)
      else
        render_silk(html, silk_pdf)
        render_browser(html, browser_pdf)
      end

      pdf_to_png(silk_pdf, silk_png)
      pdf_to_png(browser_pdf, browser_png)

      diff = image_diff(browser_png, silk_png)

      assert diff <= TOLERANCE,
        <<~MSG
          Visual diff too large for #{name}
          Diff pixels: #{diff}
          Silk:    #{silk_png}
          Browser: #{browser_png}
        MSG
    ensure
      if name == "remote_stylesheet"
        server&.shutdown
        thread&.join(1)
      end
    end
  end
end
