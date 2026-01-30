# frozen_string_literal: true

require_relative "test_helper"
require_relative "support/visual_helpers"
require "webrick"

class VisualRegressionTest < Minitest::Test
  include VisualHelpers

  TMP_DIR = VisualHelpers::TMP_DIR
  TOLERANCE = (ENV["VISUAL_TOLERANCE"] || 500).to_i
  TOLERANCE_OVERRIDES = {
    "base_href_filesystem" => 1500,
    "remote_stylesheet_redirect" => 1500,
    "remote_stylesheet_import" => 2000,
    "solid_borders_multicolor" => 3000
  }.freeze

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

      server = nil
      thread = nil

      if name.start_with?("remote_")
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

        case name
        when "remote_stylesheet"
          server.mount_proc "/remote.css" do |_req, res|
            res.status = 200
            res["Content-Type"] = "text/css"
            res.body = File.read(File.join(scenario, "remote.css"))
          end
        when "remote_stylesheet_redirect"
          server.mount_proc "/redirect.css" do |_req, res|
            res.status = 302
            res["Location"] = "/final.css"
            res.body = ""
          end

          server.mount_proc "/final.css" do |_req, res|
            res.status = 200
            res["Content-Type"] = "text/css"
            res.body = File.read(File.join(scenario, "final.css"))
          end
        when "remote_stylesheet_import"
          server.mount_proc "/remote.css" do |_req, res|
            res.status = 200
            res["Content-Type"] = "text/css"
            res.body = File.read(File.join(scenario, "remote.css"))
          end

          server.mount_proc "/import.css" do |_req, res|
            res.status = 200
            res["Content-Type"] = "text/css"
            res.body = File.read(File.join(scenario, "import.css"))
          end
        else
          flunk "Unhandled remote scenario: #{name}"
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

      tolerance = TOLERANCE_OVERRIDES.fetch(name, TOLERANCE)

      assert diff <= tolerance,
        <<~MSG
          Visual diff too large for #{name}
          Diff pixels: #{diff}
          Allowed: #{tolerance}
          Silk:    #{silk_png}
          Browser: #{browser_png}
        MSG
    ensure
      server&.shutdown
      thread&.join(1)
    end
  end
end
