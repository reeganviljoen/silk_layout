# frozen_string_literal: true

require "strscan"

module SilkLayout
  module CSS
    module Values
      NUMBER = /[-+]?(?:\d+(?:\.\d+)?|\.\d+)/
      LENGTH = /\A(?<number>#{NUMBER.source})(?<unit>px|%)?\z/i
      CALC = /\Acalc\((?<expression>.*)\)\z/i

      NAMED_LENGTHS = {
        "thin" => 1,
        "medium" => 3,
        "thick" => 5
      }.freeze

      Term = Struct.new(:value, :unit)

      class Length
        attr_reader :type, :value, :unit, :terms

        def self.parse(value)
          raw = value.to_s.strip
          normalized = raw.downcase
          return new(:auto) if normalized.empty? || normalized == "auto" || normalized == "none"

          named = NAMED_LENGTHS[normalized]
          return new(:length, value: named.to_f, unit: "px") if named

          calc_match = raw.match(CALC)
          if calc_match
            parsed = parse_calc(calc_match[:expression])
            return parsed if parsed

            return new(:length, value: raw.to_f, unit: "px")
          end

          match = raw.match(LENGTH)
          return new(:length, value: match[:number].to_f, unit: (match[:unit] || "px").downcase) if match

          new(:length, value: raw.to_f, unit: "px")
        end

        def self.parse_calc(expression)
          scanner = StringScanner.new(expression)
          terms = []
          sign = 1

          until scanner.eos?
            scanner.skip(/\s+/)

            operator = scanner.scan(/[+-]/)
            sign = (operator == "-") ? -1 : 1 if operator
            scanner.skip(/\s+/)

            token = scanner.scan(/(?:\d+(?:\.\d+)?|\.\d+)(?:px|%)?/i)
            return nil unless token

            length = parse(token)
            return nil unless length.type == :length

            terms << Term.new(length.value * sign, length.unit)
            scanner.skip(/\s+/)

            return nil unless scanner.eos? || scanner.peek(1).match?(/[+-]/)
          end

          return nil if terms.empty?

          new(:calc, terms: terms)
        end

        def initialize(type, value: 0, unit: nil, terms: [])
          @type = type
          @value = value
          @unit = unit
          @terms = terms
        end

        def resolve(reference: nil, default: 0)
          case type
          when :auto
            default
          when :length
            return default if unit == "%" && reference.nil?

            (unit == "%") ? reference * value / 100.0 : value
          when :calc
            return default if terms.any? { |term| term.unit == "%" } && reference.nil?

            terms.sum do |term|
              (term.unit == "%") ? reference * term.value / 100.0 : term.value
            end
          else
            default
          end
        end

        def reference_relative?
          return true if type == :length && unit == "%"
          return true if type == :calc && terms.any? { |term| term.unit == "%" }

          false
        end
      end

      module_function

      def length(value)
        value.is_a?(Length) ? value : Length.parse(value)
      end

      def resolve_length(value, reference: nil, default: 0)
        length(value).resolve(reference: reference, default: default)
      end

      def reference_relative?(value)
        length(value).reference_relative?
      end

      def split_tokens(value)
        tokens = []
        current = +""
        depth = 0

        value.to_s.each_char do |char|
          case char
          when "("
            depth += 1
            current << char
          when ")"
            depth -= 1 if depth.positive?
            current << char
          when /\s/
            if depth.zero?
              tokens << current unless current.empty?
              current = +""
            else
              current << char
            end
          else
            current << char
          end
        end

        tokens << current unless current.empty?
        tokens
      end

      def expanded_edges(value)
        tokens = split_tokens(value)

        case tokens.length
        when 0
          {top: nil, right: nil, bottom: nil, left: nil}
        when 1
          {top: tokens[0], right: tokens[0], bottom: tokens[0], left: tokens[0]}
        when 2
          {top: tokens[0], right: tokens[1], bottom: tokens[0], left: tokens[1]}
        when 3
          {top: tokens[0], right: tokens[1], bottom: tokens[2], left: tokens[1]}
        else
          {top: tokens[0], right: tokens[1], bottom: tokens[2], left: tokens[3]}
        end
      end
    end
  end
end
