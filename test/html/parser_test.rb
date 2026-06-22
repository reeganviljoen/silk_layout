# frozen_string_literal: true

require_relative "../test_helper"
require "fileutils"
require "tmpdir"
require "webrick"

class HTMLParserTest < Minitest::Test
  def test_extracts_inline_linked_and_imported_stylesheets
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "import.css"), ".imported { color: green; }")
      File.write(File.join(dir, "local.css"), "@import 'import.css'; .linked { color: red; }")
      input = File.join(dir, "input.html")
      html = <<~HTML
        <!doctype html>
        <html>
          <head>
            <style>.inline { color: blue; }</style>
            <link rel="stylesheet" href="local.css">
            <link rel="alternate" href="ignored.css">
            <link rel="stylesheet" href="">
          </head>
          <body><p class="inline linked imported">Hello</p></body>
        </html>
      HTML
      File.write(input, html)

      root, stylesheets = SilkLayout::HTML::Parser.parse_document(html, url: input)

      assert_equal "html", root.tag
      assert_equal 2, stylesheets.length
      assert_includes stylesheets[0], ".inline"
      assert_includes stylesheets[1], ".imported"
      assert_includes stylesheets[1], ".linked"
    end
  end

  def test_base_href_resolves_image_source_urls
    Dir.mktmpdir do |dir|
      asset_dir = File.join(dir, "assets")
      FileUtils.mkdir_p(asset_dir)
      base = SilkLayout::HTML::Parser.file_uri_for(Pathname.new(asset_dir)).to_s
      html = <<~HTML
        <!doctype html>
        <html>
          <head><base href="#{base}"></head>
          <body><img src="images/checker.png"></body>
        </html>
      HTML

      root, = SilkLayout::HTML::Parser.parse_document(html, url: File.join(dir, "input.html"))
      image = find_node(root) { |node| node.element? && node.tag == "img" }

      assert_match %r{/assets/images/checker\.png\z}, image.resolved_source_url.to_s
    end
  end

  def test_fetches_http_stylesheet_redirects
    with_server do |server, base_url|
      server.mount_proc "/redirect.css" do |_req, res|
        res.status = 302
        res["Location"] = "/final.css"
      end

      server.mount_proc "/final.css" do |_req, res|
        res.status = 200
        res["Content-Type"] = "text/css"
        res.body = ".remote { color: red; }"
      end

      html = <<~HTML
        <!doctype html>
        <html>
          <head><link rel="stylesheet" href="#{base_url}/redirect.css"></head>
          <body><p class="remote">Remote</p></body>
        </html>
      HTML

      _root, stylesheets = SilkLayout::HTML::Parser.parse_document(html, url: "#{base_url}/input.html")

      assert_equal [".remote { color: red; }"], stylesheets
    end
  end

  def test_http_stylesheet_errors_are_reported
    with_server do |server, base_url|
      server.mount_proc "/missing-location.css" do |_req, res|
        res.status = 302
      end

      server.mount_proc "/loop.css" do |_req, res|
        res.status = 302
        res["Location"] = "/loop.css"
      end

      server.mount_proc "/missing.css" do |_req, res|
        res.status = 404
      end

      error = assert_raises(RuntimeError) do
        SilkLayout::HTML::Parser.fetch_http(URI("#{base_url}/missing-location.css"))
      end
      assert_match(/Missing redirect location/, error.message)

      error = assert_raises(RuntimeError) do
        SilkLayout::HTML::Parser.fetch_http(URI("#{base_url}/loop.css"))
      end
      assert_match(/Too many redirects/, error.message)

      error = assert_raises(RuntimeError) do
        SilkLayout::HTML::Parser.fetch_http(URI("#{base_url}/missing.css"))
      end
      assert_match(/HTTP 404/, error.message)
    end
  end

  def test_file_stylesheet_errors_include_missing_and_unsupported_scheme
    Dir.mktmpdir do |dir|
      base = SilkLayout::HTML::Parser.file_uri_for(Pathname.new(dir))

      error = assert_raises(RuntimeError) do
        SilkLayout::HTML::Parser.fetch_stylesheet("missing.css", base, {})
      end
      assert_match(/Stylesheet not found/, error.message)

      error = assert_raises(RuntimeError) do
        SilkLayout::HTML::Parser.fetch_stylesheet("ftp://example.test/site.css", base, {})
      end
      assert_match(/Unsupported stylesheet scheme/, error.message)
    end
  end

  private

  def with_server
    server = WEBrick::HTTPServer.new(
      Port: 0,
      BindAddress: "127.0.0.1",
      Logger: WEBrick::Log.new(File::NULL),
      AccessLog: []
    )
    thread = Thread.new { server.start }
    thread.abort_on_exception = true

    yield server, "http://127.0.0.1:#{server.config[:Port]}"
  ensure
    server&.shutdown
    thread&.join(1)
  end

  def find_node(node, &block)
    return node if block.call(node)

    node.children.each do |child|
      found = find_node(child, &block)
      return found if found
    end

    nil
  end
end
