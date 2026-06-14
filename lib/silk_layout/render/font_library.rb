# frozen_string_literal: true

require "hexapdf"

module SilkLayout
  module Render
    class FontLibrary
      BASE_FONTS = {
        helvetica: {
          normal: {
            normal: "Helvetica",
            italic: "Helvetica-Oblique"
          },
          bold: {
            normal: "Helvetica-Bold",
            italic: "Helvetica-BoldOblique"
          }
        },
        times: {
          normal: {
            normal: "Times-Roman",
            italic: "Times-Italic"
          },
          bold: {
            normal: "Times-Bold",
            italic: "Times-BoldItalic"
          }
        },
        courier: {
          normal: {
            normal: "Courier",
            italic: "Courier-Oblique"
          },
          bold: {
            normal: "Courier-Bold",
            italic: "Courier-BoldOblique"
          }
        }
      }.freeze

      FAMILY_ALIASES = {
        "arial" => :helvetica,
        "helvetica" => :helvetica,
        "sans-serif" => :helvetica,
        "sans serif" => :helvetica,
        "times" => :times,
        "times new roman" => :times,
        "serif" => :times,
        "courier" => :courier,
        "courier new" => :courier,
        "monospace" => :courier
      }.freeze

      class << self
        def metrics(font_family, font_weight: "normal", font_style: "normal")
          font_name = resolve_font_name(font_family, font_weight: font_weight, font_style: font_style)
          font = font_wrapper(font_name)

          {
            font_name: font_name,
            font: font,
            ascender: normalized_metric(font, :ascender),
            descender: normalized_metric(font, :descender)
          }
        end

        def measure_text(text, font_size:, font_family:, font_weight: "normal", font_style: "normal")
          return 0 if text.to_s.empty?

          font = metrics(font_family, font_weight: font_weight, font_style: font_style)[:font]
          glyph_width = font.decode_utf8(text.to_s).sum(&:width)
          glyph_width * font_size / 1000.0
        end

        def resolve_font_name(font_family, font_weight: "normal", font_style: "normal")
          family = normalized_family(font_family)
          weight = bold?(font_weight) ? :bold : :normal
          style = italic?(font_style) ? :italic : :normal

          BASE_FONTS.fetch(family, BASE_FONTS[:helvetica]).fetch(weight).fetch(style)
        end

        private

        def font_wrapper(font_name)
          @document ||= HexaPDF::Document.new
          @fonts ||= {}
          @fonts[font_name] ||= @document.fonts.add(font_name)
        end

        def normalized_metric(font, metric_name)
          wrapped_font = font.instance_variable_get(:@wrapped_font)
          return 0 unless wrapped_font

          wrapped_font.public_send(metric_name).to_f * font.scaling_factor
        end

        def normalized_family(font_family)
          candidates(font_family).each do |candidate|
            mapped = FAMILY_ALIASES[candidate]
            return mapped if mapped
          end

          :helvetica
        end

        def candidates(font_family)
          font_family.to_s.split(",").map do |family|
            family.to_s.strip.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'").downcase
          end.reject(&:empty?)
        end

        def bold?(font_weight)
          weight = font_weight.to_s.strip.downcase
          return true if weight == "bold"
          return false if weight.empty? || weight == "normal"

          weight.to_i >= 600
        end

        def italic?(font_style)
          %w[italic oblique].include?(font_style.to_s.strip.downcase)
        end
      end
    end
  end
end
