# frozen_string_literal: true

require "net/http"
require "nokogiri"
require "uri"

module SilkLayout
  module HTML
    class Parser
      def self.parse_document(html, url: nil)
        document = Nokogiri::HTML(html)

        base_uri = base_uri_for(document, url)
        stylesheets = extract_stylesheets!(document, base_uri)

        [Node.from_nokogiri(document.root), stylesheets]
      end

      def self.extract_stylesheets!(document, base_uri)
        stylesheets = []
        cache = {}

        document.css("style, link").each do |node|
          if node.name == "style"
            stylesheets << node.content.to_s
            node.remove
            next
          end

          next unless node.name == "link"

          rel = node["rel"].to_s.downcase.split
          next unless rel.include?("stylesheet")

          href = node["href"].to_s.strip
          next if href.empty?

          stylesheets << fetch_stylesheet(href, base_uri, cache)
          node.remove
        end

        stylesheets
      end

      def self.base_uri_for(document, url)
        doc_uri = normalize_document_url(url)

        base_href = document.at_css("base[href]")&.[]("href")
        return doc_uri unless base_href

        normalize_href(base_href.to_s, doc_uri)
      end

      def self.normalize_document_url(url)
        return default_workdir_uri unless url

        uri = URI.parse(url.to_s)
        return uri if uri.scheme

        path = Pathname.new(url.to_s).expand_path
        file_uri_for(path)
      rescue URI::InvalidURIError
        path = Pathname.new(url.to_s).expand_path
        file_uri_for(path)
      end

      def self.default_workdir_uri
        file_uri_for(Pathname.pwd)
      end

      def self.file_uri_for(path)
        p = path
        p = p.dirname if p.file?

        dir = p.to_s
        dir = "#{dir}/" unless dir.end_with?("/")

        URI::Generic.build(scheme: "file", path: dir)
      end

      def self.fetch_stylesheet(href, base_uri, cache)
        resolved = normalize_href(href, base_uri)
        key = resolved.to_s
        return cache[key] if cache.key?(key)

        css =
          case resolved.scheme
          when "file", nil
            path = uri_unescape(resolved.path)
            raise "Stylesheet not found: #{path}" unless File.exist?(path)

            File.read(path)
          when "http", "https"
            fetch_http(resolved)
          else
            raise "Unsupported stylesheet scheme: #{resolved.scheme} (#{resolved})"
          end

        css = inline_css_imports(css, resolved, cache)
        cache[key] = css
      end

      def self.normalize_href(href, base_uri)
        href = href.to_s
        uri = URI.parse(href)
        return uri if uri.scheme

        URI.join(base_uri.to_s, href)
      rescue URI::InvalidURIError
        URI.join(base_uri.to_s, URI::DEFAULT_PARSER.escape(href))
      end

      def self.fetch_http(uri)
        current = uri
        redirects = 0

        loop do
          http = Net::HTTP.new(current.host, current.port)
          http.use_ssl = (current.scheme == "https")
          http.open_timeout = 10
          http.read_timeout = 10

          request = Net::HTTP::Get.new(current)
          request["User-Agent"] = "SilkLayout/#{SilkLayout::VERSION}"

          response = http.request(request)

          case response
          when Net::HTTPSuccess
            return response.body.to_s
          when Net::HTTPRedirection
            location = response["location"].to_s
            raise "Missing redirect location for #{current}" if location.empty?

            redirects += 1
            raise "Too many redirects fetching #{uri}" if redirects > 5

            current = URI.join(current.to_s, location)
          else
            raise "Failed to fetch #{current} (HTTP #{response.code})"
          end
        end
      end

      def self.inline_css_imports(css, stylesheet_uri, cache)
        return css unless css.include?("@import")

        base = stylesheet_base_uri(stylesheet_uri)
        remaining = css.dup
        inlined = +""
        seen = {}

        20.times do
          m = remaining.match(/@import\s+(?:url\()?
            \s*['"]?([^'")\s;]+)['"]?
            \s*\)?\s*;/ix)
          break unless m

          href = m[1]
          break if seen[href]

          seen[href] = true
          import_uri = normalize_href(href, base)
          imported = fetch_stylesheet(import_uri.to_s, base, cache)

          inlined << imported.to_s << "\n"
          remaining.sub!(m[0], "")
        end

        (inlined + remaining)
      end

      def self.stylesheet_base_uri(stylesheet_uri)
        if stylesheet_uri.scheme == "file"
          file_uri_for(Pathname.new(uri_unescape(stylesheet_uri.path)))
        else
          uri = stylesheet_uri.dup
          uri.path = uri.path.to_s.sub(/[^\/]+\z/, "")
          uri
        end
      end

      def self.uri_unescape(value)
        URI::RFC2396_PARSER.unescape(value.to_s)
      end
    end
  end
end
