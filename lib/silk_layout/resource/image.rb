# frozen_string_literal: true

require "uri"

module SilkLayout
  module Resource
    class Image
      PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b
      JPEG_START_OF_FRAME_MARKERS = [
        0xC0,
        0xC1,
        0xC2,
        0xC3,
        0xC5,
        0xC6,
        0xC7,
        0xC9,
        0xCA,
        0xCB,
        0xCD,
        0xCE,
        0xCF
      ].freeze

      attr_reader :uri, :path, :width, :height

      def self.load(source)
        uri = normalize_uri(source)
        return nil unless uri
        return nil unless uri.scheme.nil? || uri.scheme == "file"

        path = (uri.scheme == "file") ? uri_unescape(uri.path) : uri.to_s
        return nil unless File.file?(path)

        dimensions = read_dimensions(path)
        return nil unless dimensions

        new(uri: uri, path: path, width: dimensions[0], height: dimensions[1])
      rescue URI::InvalidURIError, SystemCallError
        nil
      end

      def initialize(uri:, path:, width:, height:)
        @uri = uri
        @path = path
        @width = width
        @height = height
      end

      def aspect_ratio
        return nil unless width&.positive? && height&.positive?

        width.to_f / height
      end

      def self.normalize_uri(source)
        return source if source.is_a?(URI)

        raw = source.to_s.strip
        return nil if raw.empty?

        URI.parse(raw)
      end

      def self.read_dimensions(path)
        png_dimensions(path) || jpeg_dimensions(path)
      end

      def self.png_dimensions(path)
        File.open(path, "rb") do |file|
          header = file.read(24)
          return nil unless header&.bytesize == 24
          return nil unless header.start_with?(PNG_SIGNATURE)
          return nil unless header.byteslice(12, 4) == "IHDR"

          [
            header.byteslice(16, 4).unpack1("N"),
            header.byteslice(20, 4).unpack1("N")
          ]
        end
      end

      def self.jpeg_dimensions(path)
        File.open(path, "rb") do |file|
          return nil unless file.read(2)&.bytes == [0xFF, 0xD8]

          loop do
            marker = next_jpeg_marker(file)
            return nil unless marker
            return nil if marker == 0xD9 || marker == 0xDA
            next if standalone_jpeg_marker?(marker)

            length = read_uint16(file)
            return nil unless length && length >= 2

            if JPEG_START_OF_FRAME_MARKERS.include?(marker)
              frame = file.read(5)
              return nil unless frame&.bytesize == 5

              return [
                frame.byteslice(3, 2).unpack1("n"),
                frame.byteslice(1, 2).unpack1("n")
              ]
            end

            file.seek(length - 2, IO::SEEK_CUR)
          end
        end
      end

      def self.next_jpeg_marker(file)
        loop do
          byte = file.read(1)
          return nil unless byte
          next unless byte.ord == 0xFF

          loop do
            marker = file.read(1)
            return nil unless marker
            next if marker.ord == 0xFF

            return marker.ord unless marker.ord == 0x00
          end
        end
      end

      def self.standalone_jpeg_marker?(marker)
        marker == 0x01 || (0xD0..0xD8).cover?(marker)
      end

      def self.read_uint16(file)
        bytes = file.read(2)
        return nil unless bytes&.bytesize == 2

        bytes.unpack1("n")
      end

      def self.uri_unescape(value)
        URI::RFC2396_PARSER.unescape(value.to_s)
      end

      private_class_method :normalize_uri,
        :png_dimensions,
        :jpeg_dimensions,
        :next_jpeg_marker,
        :standalone_jpeg_marker?,
        :read_uint16,
        :uri_unescape
    end
  end
end
