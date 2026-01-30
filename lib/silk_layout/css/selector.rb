# frozen_string_literal: true

module SilkLayout
  module CSS
    class Selector
      def initialize(raw)
        @raw = raw.to_s.strip
        @steps = parse_steps(@raw)
      end

      def match?(node)
        return false unless node.respond_to?(:element?)
        return false unless node.element?
        return false if node.tag.nil?

        return false unless step_match?(@steps.last[:simple], node)

        current = node
        i = @steps.length - 2
        while i >= 0
          comb = @steps[i + 1][:combinator]
          simple = @steps[i][:simple]

          case comb
          when :child
            current = current.parent
            return false unless current
            return false unless step_match?(simple, current)
          when :descendant
            current = find_ancestor(current.parent, simple)
            return false unless current
          else
            return false
          end

          i -= 1
        end

        true
      end

      def specificity
        ids = 0
        classes = 0
        elements = 0

        @steps.each do |step|
          simple = step[:simple]
          ids += 1 if simple[:id]
          classes += simple[:classes].length
          elements += 1 if simple[:tag]
        end

        [ids, classes, elements]
      end

      private

      def parse_steps(raw)
        tokens = tokenize(raw)
        parts = []
        pending_combinator = nil

        tokens.each do |tok|
          if tok == ">"
            pending_combinator = :child
            next
          end

          if tok == " "
            pending_combinator ||= :descendant
            next
          end

          parts << {simple: parse_simple(tok), combinator: pending_combinator}
          pending_combinator = nil
        end

        # Default combinator between left/right parts is descendant.
        # Combinator is stored on the RIGHT step to indicate how it relates to the LEFT.
        parts.each_with_index do |part, idx|
          next if idx == 0
          part[:combinator] ||= :descendant
        end

        parts
      end

      def tokenize(raw)
        raw = raw.strip
        tokens = []
        buf = +""
        in_space = false

        raw.each_char do |ch|
          if ch == ">"
            tokens << buf unless buf.empty?
            buf = +""
            tokens << ">"
            in_space = false
            next
          end

          if ch.match?(/\s/)
            tokens << buf unless buf.empty?
            buf = +""
            tokens << " " unless in_space
            in_space = true
            next
          end

          in_space = false
          buf << ch
        end

        tokens << buf unless buf.empty?
        tokens.reject(&:empty?)
      end

      def parse_simple(token)
        tag = nil
        id = nil
        classes = []

        rest = token.to_s
        if rest.match?(/\A[a-zA-Z][a-zA-Z0-9_-]*/)
          m = rest.match(/\A([a-zA-Z][a-zA-Z0-9_-]*)/)
          tag = m[1]
          rest = rest[m[1].length..]
        end

        rest.scan(/([#.])([a-zA-Z0-9_-]+)/) do |kind, value|
          if kind == "#"
            id = value
          else
            classes << value
          end
        end

        {tag: tag, id: id, classes: classes}
      end

      def step_match?(simple, node)
        return false if simple[:tag] && node.tag != simple[:tag]
        return false if simple[:id] && node.attributes["id"] != simple[:id]

        if simple[:classes].any?
          node_classes = node.attributes.fetch("class", "").split
          return false unless simple[:classes].all? { |c| node_classes.include?(c) }
        end

        true
      end

      def find_ancestor(node, simple)
        current = node
        while current
          return current if step_match?(simple, current)
          current = current.parent
        end
        nil
      end
    end
  end
end
