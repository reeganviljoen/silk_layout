# frozen_string_literal: true

module SilkLayout
  module CSS
    class Color
      attr_reader :red,
        :green,
        :blue,
        :alpha,
        :normalized

      NAMED_COLOR_HEX = {
        "aliceblue" => "f0f8ff",
        "antiquewhite" => "faebd7",
        "aqua" => "00ffff",
        "aquamarine" => "7fffd4",
        "azure" => "f0ffff",
        "beige" => "f5f5dc",
        "bisque" => "ffe4c4",
        "black" => "000000",
        "blanchedalmond" => "ffebcd",
        "blue" => "0000ff",
        "blueviolet" => "8a2be2",
        "brown" => "a52a2a",
        "burlywood" => "deb887",
        "cadetblue" => "5f9ea0",
        "chartreuse" => "7fff00",
        "chocolate" => "d2691e",
        "coral" => "ff7f50",
        "cornflowerblue" => "6495ed",
        "cornsilk" => "fff8dc",
        "crimson" => "dc143c",
        "cyan" => "00ffff",
        "darkblue" => "00008b",
        "darkcyan" => "008b8b",
        "darkgoldenrod" => "b8860b",
        "darkgray" => "a9a9a9",
        "darkgreen" => "006400",
        "darkgrey" => "a9a9a9",
        "darkkhaki" => "bdb76b",
        "darkmagenta" => "8b008b",
        "darkolivegreen" => "556b2f",
        "darkorange" => "ff8c00",
        "darkorchid" => "9932cc",
        "darkred" => "8b0000",
        "darksalmon" => "e9967a",
        "darkseagreen" => "8fbc8f",
        "darkslateblue" => "483d8b",
        "darkslategray" => "2f4f4f",
        "darkslategrey" => "2f4f4f",
        "darkturquoise" => "00ced1",
        "darkviolet" => "9400d3",
        "deeppink" => "ff1493",
        "deepskyblue" => "00bfff",
        "dimgray" => "696969",
        "dimgrey" => "696969",
        "dodgerblue" => "1e90ff",
        "firebrick" => "b22222",
        "floralwhite" => "fffaf0",
        "forestgreen" => "228b22",
        "fuchsia" => "ff00ff",
        "gainsboro" => "dcdcdc",
        "ghostwhite" => "f8f8ff",
        "gold" => "ffd700",
        "goldenrod" => "daa520",
        "gray" => "808080",
        "green" => "008000",
        "greenyellow" => "adff2f",
        "grey" => "808080",
        "honeydew" => "f0fff0",
        "hotpink" => "ff69b4",
        "indianred" => "cd5c5c",
        "indigo" => "4b0082",
        "ivory" => "fffff0",
        "khaki" => "f0e68c",
        "lavender" => "e6e6fa",
        "lavenderblush" => "fff0f5",
        "lawngreen" => "7cfc00",
        "lemonchiffon" => "fffacd",
        "lightblue" => "add8e6",
        "lightcoral" => "f08080",
        "lightcyan" => "e0ffff",
        "lightgoldenrodyellow" => "fafad2",
        "lightgray" => "d3d3d3",
        "lightgreen" => "90ee90",
        "lightgrey" => "d3d3d3",
        "lightpink" => "ffb6c1",
        "lightsalmon" => "ffa07a",
        "lightseagreen" => "20b2aa",
        "lightskyblue" => "87cefa",
        "lightslategray" => "778899",
        "lightslategrey" => "778899",
        "lightsteelblue" => "b0c4de",
        "lightyellow" => "ffffe0",
        "lime" => "00ff00",
        "limegreen" => "32cd32",
        "linen" => "faf0e6",
        "magenta" => "ff00ff",
        "maroon" => "800000",
        "mediumaquamarine" => "66cdaa",
        "mediumblue" => "0000cd",
        "mediumorchid" => "ba55d3",
        "mediumpurple" => "9370db",
        "mediumseagreen" => "3cb371",
        "mediumslateblue" => "7b68ee",
        "mediumspringgreen" => "00fa9a",
        "mediumturquoise" => "48d1cc",
        "mediumvioletred" => "c71585",
        "midnightblue" => "191970",
        "mintcream" => "f5fffa",
        "mistyrose" => "ffe4e1",
        "moccasin" => "ffe4b5",
        "navajowhite" => "ffdead",
        "navy" => "000080",
        "oldlace" => "fdf5e6",
        "olive" => "808000",
        "olivedrab" => "6b8e23",
        "orange" => "ffa500",
        "orangered" => "ff4500",
        "orchid" => "da70d6",
        "palegoldenrod" => "eee8aa",
        "palegreen" => "98fb98",
        "paleturquoise" => "afeeee",
        "palevioletred" => "db7093",
        "papayawhip" => "ffefd5",
        "peachpuff" => "ffdab9",
        "peru" => "cd853f",
        "pink" => "ffc0cb",
        "plum" => "dda0dd",
        "powderblue" => "b0e0e6",
        "purple" => "800080",
        "rebeccapurple" => "663399",
        "red" => "ff0000",
        "rosybrown" => "bc8f8f",
        "royalblue" => "4169e1",
        "saddlebrown" => "8b4513",
        "salmon" => "fa8072",
        "sandybrown" => "f4a460",
        "seagreen" => "2e8b57",
        "seashell" => "fff5ee",
        "sienna" => "a0522d",
        "silver" => "c0c0c0",
        "skyblue" => "87ceeb",
        "slateblue" => "6a5acd",
        "slategray" => "708090",
        "slategrey" => "708090",
        "snow" => "fffafa",
        "springgreen" => "00ff7f",
        "steelblue" => "4682b4",
        "tan" => "d2b48c",
        "teal" => "008080",
        "thistle" => "d8bfd8",
        "tomato" => "ff6347",
        "turquoise" => "40e0d0",
        "violet" => "ee82ee",
        "wheat" => "f5deb3",
        "white" => "ffffff",
        "whitesmoke" => "f5f5f5",
        "yellow" => "ffff00",
        "yellowgreen" => "9acd32"
      }.freeze

      NAMED_COLORS = NAMED_COLOR_HEX.transform_values do |hex|
        hex.scan(/../).map { |component| component.to_i(16) }
      end.freeze

      FUNCTION_PATTERN = /\A([a-z]+)\((.*)\)\z/
      NUMBER_PATTERN = /\A[-+]?(?:\d+\.?\d*|\.\d+)\z/

      def self.parse(value)
        return value if value.is_a?(self)

        raw = value.to_s.strip
        return nil if raw.empty?

        normalized = raw.downcase
        return new(0, 0, 0, alpha: 0, normalized: "transparent") if normalized == "transparent"

        if (rgb = NAMED_COLORS[normalized])
          return new(*rgb, normalized: normalized)
        end

        return parse_hex(normalized) if normalized.start_with?("#")

        match = normalized.match(FUNCTION_PATTERN)
        return nil unless match

        case match[1]
        when "rgb", "rgba"
          parse_rgb_function(match[1], match[2], normalized)
        when "hsl", "hsla"
          parse_hsl_function(match[1], match[2], normalized)
        end
      end

      # The renderer currently paints RGB only. Alpha is kept on parsed colors;
      # conversion treats fully transparent colors as not paintable and ignores
      # partial alpha as a best-effort fallback.
      def self.rgb(value)
        color = parse(value)
        return nil unless color
        return nil if color.transparent?

        color.rgb
      end

      def initialize(red, green, blue, normalized:, alpha: 1.0)
        @red = clamp_byte(red)
        @green = clamp_byte(green)
        @blue = clamp_byte(blue)
        @alpha = clamp_unit(alpha)
        @normalized = normalized
      end

      def rgb
        [red, green, blue]
      end

      def transparent?
        alpha <= 0
      end

      def to_sym
        normalized.to_sym
      end

      def to_s
        normalized
      end

      def self.parse_hex(value)
        hex = value.delete_prefix("#")
        return nil unless hex.match?(/\A(?:[0-9a-f]{3}|[0-9a-f]{6})\z/)

        expanded = (hex.length == 3) ? hex.chars.flat_map { |char| [char, char] }.join : hex
        new(*expanded.scan(/../).map { |component| component.to_i(16) }, normalized: value)
      end
      private_class_method :parse_hex

      def self.parse_rgb_function(name, content, normalized)
        components = split_function_arguments(content)
        return nil unless [3, 4].include?(components.length)
        return nil if name == "rgba" && components.length < 4

        red = parse_rgb_component(components[0])
        green = parse_rgb_component(components[1])
        blue = parse_rgb_component(components[2])
        alpha = components[3] ? parse_alpha(components[3]) : 1
        return nil if [red, green, blue, alpha].any?(&:nil?)

        new(red, green, blue, alpha: alpha, normalized: normalized)
      end
      private_class_method :parse_rgb_function

      def self.parse_hsl_function(name, content, normalized)
        components = split_function_arguments(content)
        return nil unless [3, 4].include?(components.length)
        return nil if name == "hsla" && components.length < 4

        hue = parse_hue(components[0])
        saturation = parse_percentage(components[1])
        lightness = parse_percentage(components[2])
        alpha = components[3] ? parse_alpha(components[3]) : 1
        return nil if [hue, saturation, lightness, alpha].any?(&:nil?)

        new(*hsl_to_rgb(hue, saturation, lightness), alpha: alpha, normalized: normalized)
      end
      private_class_method :parse_hsl_function

      def self.split_function_arguments(content)
        raw = content.to_s.strip
        return [] if raw.empty?

        parts =
          if raw.include?(",")
            raw.split(",").map(&:strip)
          else
            values, alpha = raw.split("/", 2).map(&:strip)
            values.to_s.split(/\s+/).tap { |items| items << alpha if alpha }
          end

        if parts.last&.include?("/")
          value, alpha = parts.pop.split("/", 2).map(&:strip)
          parts << value
          parts << alpha
        end

        parts
      end
      private_class_method :split_function_arguments

      def self.parse_rgb_component(value)
        raw = value.to_s.strip
        if raw.end_with?("%")
          percentage = parse_number(raw.delete_suffix("%"))
          return nil unless percentage

          clamp_byte(percentage * 255 / 100.0)
        else
          number = parse_number(raw)
          return nil unless number

          clamp_byte(number)
        end
      end
      private_class_method :parse_rgb_component

      def self.parse_alpha(value)
        raw = value.to_s.strip
        if raw.end_with?("%")
          percentage = parse_number(raw.delete_suffix("%"))
          return nil unless percentage

          clamp_unit(percentage / 100.0)
        else
          number = parse_number(raw)
          return nil unless number

          clamp_unit(number)
        end
      end
      private_class_method :parse_alpha

      def self.parse_hue(value)
        raw = value.to_s.strip
        multiplier =
          if raw.end_with?("turn")
            raw = raw.delete_suffix("turn")
            360
          elsif raw.end_with?("deg")
            raw = raw.delete_suffix("deg")
            1
          elsif raw.end_with?("rad")
            raw = raw.delete_suffix("rad")
            180 / Math::PI
          else
            1
          end

        number = parse_number(raw)
        return nil unless number

        (number * multiplier) % 360
      end
      private_class_method :parse_hue

      def self.parse_percentage(value)
        raw = value.to_s.strip
        return nil unless raw.end_with?("%")

        number = parse_number(raw.delete_suffix("%"))
        return nil unless number

        clamp_unit(number / 100.0)
      end
      private_class_method :parse_percentage

      def self.parse_number(value)
        raw = value.to_s.strip
        return nil unless raw.match?(NUMBER_PATTERN)

        raw.to_f
      end
      private_class_method :parse_number

      def self.hsl_to_rgb(hue, saturation, lightness)
        chroma = (1 - ((2 * lightness) - 1).abs) * saturation
        hue_segment = hue / 60.0
        x = chroma * (1 - ((hue_segment % 2) - 1).abs)
        match = lightness - (chroma / 2)

        red, green, blue =
          case hue_segment
          when 0...1
            [chroma, x, 0]
          when 1...2
            [x, chroma, 0]
          when 2...3
            [0, chroma, x]
          when 3...4
            [0, x, chroma]
          when 4...5
            [x, 0, chroma]
          else
            [chroma, 0, x]
          end

        [
          clamp_byte((red + match) * 255),
          clamp_byte((green + match) * 255),
          clamp_byte((blue + match) * 255)
        ]
      end
      private_class_method :hsl_to_rgb

      def self.clamp_byte(value)
        value.to_f.round.clamp(0, 255)
      end
      private_class_method :clamp_byte

      def self.clamp_unit(value)
        value.to_f.clamp(0, 1)
      end
      private_class_method :clamp_unit

      def clamp_byte(value)
        value.to_f.round.clamp(0, 255)
      end

      def clamp_unit(value)
        value.to_f.clamp(0, 1)
      end
    end
  end
end
