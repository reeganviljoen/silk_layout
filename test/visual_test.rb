# frozen_string_literal: true

require_relative "test_helper"
require_relative "support/visual_helpers"

class VisualRegressionTest < Minitest::Test
  include VisualHelpers

  TMP_DIR   = VisualHelpers::TMP_DIR
  TOLERANCE = 10

  # Ensure tmp dir exists before each test
  def setup
    super
    FileUtils.mkdir_p(TMP_DIR)
  end

  # ----------------------------------------
  # Auto-generate one test per scenario dir
  # ----------------------------------------
  Dir["test/visual/*"].sort.each do |scenario|
    next unless File.directory?(scenario)

    name = File.basename(scenario)

    define_method("test_visual_#{name}") do
      html = File.join(scenario, "input.html")
      css  = File.join(scenario, "input.css")

      unless File.exist?(html) && File.exist?(css)
        flunk "Missing input.html or input.css in #{scenario}"
      end

      silk_pdf    = "#{TMP_DIR}/#{name}_silk.pdf"
      browser_pdf = "#{TMP_DIR}/#{name}_browser.pdf"
      silk_png    = "#{TMP_DIR}/#{name}_silk.png"
      browser_png = "#{TMP_DIR}/#{name}_browser.png"

      render_silk(html, css, silk_pdf)
      render_browser(html, css, browser_pdf)

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
    end
  end
end
