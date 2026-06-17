# frozen_string_literal: true

module SilkLayout
  module CSS
    class Selector
      def initialize(raw)
        @raw = raw.to_s.strip
        @valid = !@raw.empty?
        @steps = @valid ? parse_steps(@raw) : []
        @valid &&= @steps.any?
      end

      def match?(node)
        return false unless @valid
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
          when :adjacent
            current = previous_element_sibling(current)
            return false unless current
            return false unless step_match?(simple, current)
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
          simple_ids, simple_classes, simple_elements = simple_specificity(step[:simple])
          ids += simple_ids
          classes += simple_classes
          elements += simple_elements
        end

        [ids, classes, elements]
      end

      private

      IDENT = /[a-zA-Z][a-zA-Z0-9_-]*/
      NAME = /[a-zA-Z0-9_-]+/

      def parse_steps(raw)
        tokens = tokenize(raw)
        parts = []
        pending_combinator = nil
        expecting_simple = true

        tokens.each do |tok|
          if tok == " "
            pending_combinator ||= :descendant unless expecting_simple || parts.empty?
            next
          end

          if tok == ">" || tok == "+"
            return invalid_steps if parts.empty? || expecting_simple

            pending_combinator = (tok == ">") ? :child : :adjacent
            expecting_simple = true
            next
          end

          simple = parse_simple(tok)
          return invalid_steps unless simple

          parts << {
            simple: simple,
            combinator: parts.empty? ? nil : (pending_combinator || :descendant)
          }
          pending_combinator = nil
          expecting_simple = false
        end

        return invalid_steps if expecting_simple && parts.any?

        parts
      end

      def tokenize(raw)
        tokens = []
        buf = +""
        in_space = false
        quote = nil
        bracket_depth = 0
        paren_depth = 0

        raw.strip.each_char do |ch|
          if quote
            buf << ch
            quote = nil if ch == quote
            next
          end

          if ch == '"' || ch == "'"
            quote = ch
            buf << ch
            next
          end

          if ch == "["
            bracket_depth += 1
            buf << ch
            next
          end

          if ch == "]"
            bracket_depth -= 1
            return invalid_steps if bracket_depth.negative?

            buf << ch
            next
          end

          if ch == "("
            paren_depth += 1
            buf << ch
            next
          end

          if ch == ")"
            paren_depth -= 1
            return invalid_steps if paren_depth.negative?

            buf << ch
            next
          end

          if (ch == ">" || ch == "+") && bracket_depth.zero? && paren_depth.zero?
            tokens << buf unless buf.empty?
            buf = +""
            tokens << ch
            in_space = false
            next
          end

          if ch.match?(/\s/) && bracket_depth.zero? && paren_depth.zero?
            tokens << buf unless buf.empty?
            buf = +""
            tokens << " " unless in_space
            in_space = true
            next
          end

          in_space = false
          buf << ch
        end

        return invalid_steps if quote || !bracket_depth.zero? || !paren_depth.zero?

        tokens << buf unless buf.empty?
        tokens.reject(&:empty?)
      end

      def parse_simple(token, allow_not: true)
        tag = nil
        id = nil
        classes = []
        attributes = []
        pseudo_classes = []
        negations = []
        universal = false

        rest = token.to_s
        if rest.start_with?("*")
          universal = true
          rest = rest[1..].to_s
        elsif (m = rest.match(/\A(#{IDENT.source})/))
          tag = m[1].downcase
          rest = rest[m[1].length..]
        end

        until rest.empty?
          if (m = rest.match(/\A#(#{NAME.source})/))
            id = m[1]
            rest = rest[m[0].length..].to_s
          elsif (m = rest.match(/\A\.(#{NAME.source})/))
            classes << m[1]
            rest = rest[m[0].length..].to_s
          elsif rest.start_with?("[")
            closing = closing_index(rest, "]")
            return invalid_simple unless closing

            attribute = parse_attribute(rest[1...closing])
            return invalid_simple unless attribute

            attributes << attribute
            rest = rest[(closing + 1)..].to_s
          elsif rest.start_with?(":first-child")
            pseudo_classes << :first_child
            rest = rest[12..].to_s
          elsif rest.start_with?(":last-child")
            pseudo_classes << :last_child
            rest = rest[11..].to_s
          elsif rest.start_with?(":not(")
            return invalid_simple unless allow_not

            closing = closing_index(rest, ")")
            return invalid_simple unless closing

            inner = rest[5...closing].to_s.strip
            inner_tokens = tokenize(inner)
            return invalid_simple unless @valid && inner_tokens.length == 1

            negation = parse_simple(inner_tokens.first, allow_not: false)
            return invalid_simple unless negation

            negations << negation
            rest = rest[(closing + 1)..].to_s
          else
            return invalid_simple
          end
        end

        if tag.nil? && id.nil? && classes.empty? && attributes.empty? && pseudo_classes.empty? && negations.empty? && !universal
          return invalid_simple
        end

        {
          tag: tag,
          id: id,
          classes: classes,
          attributes: attributes,
          pseudo_classes: pseudo_classes,
          negations: negations,
          universal: universal
        }
      end

      def step_match?(simple, node)
        return false if simple[:tag] && node.tag != simple[:tag]
        return false if simple[:id] && node.attributes["id"] != simple[:id]

        if simple[:classes].any?
          node_classes = node.attributes.fetch("class", "").split
          return false unless simple[:classes].all? { |c| node_classes.include?(c) }
        end

        simple[:attributes].each do |attribute|
          return false unless node.attributes.key?(attribute[:name])
          return false if attribute.key?(:value) && node.attributes[attribute[:name]] != attribute[:value]
        end

        simple[:pseudo_classes].each do |pseudo_class|
          case pseudo_class
          when :first_child
            return false unless first_element_child?(node)
          when :last_child
            return false unless last_element_child?(node)
          else
            return false
          end
        end

        simple[:negations].each do |negation|
          return false if step_match?(negation, node)
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

      def simple_specificity(simple)
        ids = simple[:id] ? 1 : 0
        classes = simple[:classes].length + simple[:attributes].length + simple[:pseudo_classes].length
        elements = simple[:tag] ? 1 : 0

        simple[:negations].each do |negation|
          negation_ids, negation_classes, negation_elements = simple_specificity(negation)
          ids += negation_ids
          classes += negation_classes
          elements += negation_elements
        end

        [ids, classes, elements]
      end

      def parse_attribute(raw)
        m = raw.to_s.strip.match(/\A(#{IDENT.source})(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=\]]+)))?\z/)
        return nil unless m

        attribute = {name: m[1].downcase}
        value = m[2] || m[3] || m[4]
        attribute[:value] = value unless value.nil?
        attribute
      end

      def closing_index(raw, character)
        quote = nil

        raw.each_char.with_index do |ch, index|
          next if index.zero?

          if quote
            quote = nil if ch == quote
            next
          end

          if ch == '"' || ch == "'"
            quote = ch
            next
          end

          return index if ch == character
        end

        nil
      end

      def first_element_child?(node)
        element_siblings(node).first == node
      end

      def last_element_child?(node)
        element_siblings(node).last == node
      end

      def element_siblings(node)
        node.parent&.children&.select { |child| child.respond_to?(:element?) && child.element? } || []
      end

      def previous_element_sibling(node)
        siblings = node.parent&.children
        return nil unless siblings

        index = siblings.index(node)
        return nil unless index

        (index - 1).downto(0) do |candidate_index|
          candidate = siblings[candidate_index]
          return candidate if candidate.respond_to?(:element?) && candidate.element?
        end

        nil
      end

      def invalid_steps
        @valid = false
        []
      end

      def invalid_simple
        @valid = false
        nil
      end
    end
  end
end
