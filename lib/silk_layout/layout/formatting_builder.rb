# frozen_string_literal: true

module SilkLayout
  module Layout
    class FormattingBuilder
      DEFAULT_DISPLAY = {
        "html" => "block",
        "head" => "none",
        "meta" => "none",
        "title" => "none",
        "link" => "none",
        "style" => "none",
        "script" => "none",
        "body" => "block",
        "div" => "block",
        "p" => "block",
        "span" => "inline",
        "a" => "inline",
        "strong" => "inline",
        "em" => "inline",
        "br" => "inline",
        "img" => "inline",
        "h1" => "block",
        "h2" => "block",
        "h3" => "block",
        "h4" => "block",
        "h5" => "block",
        "h6" => "block",
        "ul" => "block",
        "ol" => "block",
        "li" => "block",
        "section" => "block",
        "header" => "block",
        "footer" => "block",
        "nav" => "block",
        "article" => "block"
      }.freeze

      def self.build(dom_root)
        new.build(dom_root)
      end

      def build(dom_root)
        build_box(dom_root)
      end

      private

      def build_box(node)
        box = create_box(node)
        return nil unless box

        inline_buffer = nil

        node.children.each do |child|
          child_box = build_box(child) || build_text(child)
          next unless child_box

          if box.is_a?(BlockBox) && child_box.is_a?(InlineBox)
            inline_buffer ||= AnonymousBlockBox.new
            inline_buffer.add_child(child_box)
          else
            if inline_buffer
              box.add_child(inline_buffer)
              inline_buffer = nil
            end

            box.add_child(child_box)
          end
        end

        box.add_child(inline_buffer) if inline_buffer
        box
      end

      def create_box(node)
        return nil unless node
        return nil unless node.respond_to?(:element?) && node.element?

        style = node.computed_style
        display = display_for(node, style)
        return nil if display == "none"

        box =
          case display
          when "block"
            BlockBox.new(node)
          when "flex", "inline-flex"
            FlexBox.new(node)
          when "inline"
            InlineBox.new(node)
          else
            BlockBox.new(node)
          end

        box.display = display

        if style.respond_to?(:explicit_width?) && style.explicit_width?
          box.explicit_width = true
          box.width = px(style["width"])
        else
          box.explicit_width = false
        end

        if style.respond_to?(:explicit_height?) && style.explicit_height?
          box.explicit_height = true
          box.height = px(style["height"])
        else
          box.explicit_height = false
        end

        box.margin = edge_lengths(style, "margin")
        box.padding = edge_lengths(style, "padding")

        border_styles = border_edges(style, "style", "none")
        box.border = border_edges(style, "width", nil).transform_values { |value| px(value) }

        box.border.each_key do |side|
          box.border[side] = 0 if border_styles[side] == "none"
        end

        box.has_border = box.border.values.any? { |value| value > 0 }

        default_color = box.has_border ? :black : nil

        box.border_color = {
          top: color(border_edges(style, "color", nil)[:top]) || default_color,
          right: color(border_edges(style, "color", nil)[:right]) || default_color,
          bottom: color(border_edges(style, "color", nil)[:bottom]) || default_color,
          left: color(border_edges(style, "color", nil)[:left]) || default_color
        }

        box.background_color = color(background_color(style))
        box.flex = flex_values(style)
        apply_image_data(box, node, style)

        box
      end

      def apply_image_data(box, node, style)
        return unless node.tag == "img"

        source = node.resolved_source_url || node.attributes["src"]
        image = SilkLayout::Resource::Image.load(source)

        box.replaced = true
        box.image_source = source.to_s
        box.image_resource = image
        box.intrinsic_width = image&.width
        box.intrinsic_height = image&.height

        box.width, box.height = replaced_dimensions(style, node.attributes, image)
        box.explicit_width = true
        box.explicit_height = true
      end

      def replaced_dimensions(style, attributes, image)
        attr_width = html_dimension(attributes["width"])
        attr_height = html_dimension(attributes["height"])
        css_width = style.explicit_width? ? px(style["width"]) : nil
        css_height = style.explicit_height? ? px(style["height"]) : nil

        width = css_width.nil? ? attr_width : css_width
        height = css_height.nil? ? attr_height : css_height
        ratio = image&.aspect_ratio || aspect_ratio(attr_width, attr_height)

        if width.nil? && height.nil?
          width = image&.width || 0
          height = image&.height || 0
        elsif width.nil?
          width = ratio ? height * ratio : (image&.width || 0)
        elsif height.nil?
          height = ratio ? width / ratio : (image&.height || 0)
        end

        [width.to_f, height.to_f]
      end

      def html_dimension(value)
        raw = value.to_s.strip
        return nil if raw.empty?

        raw = raw.delete_suffix("px")
        return nil unless raw.match?(/\A[-+]?\d*\.?\d+\z/)

        raw.to_f
      end

      def aspect_ratio(width, height)
        return nil unless width&.positive? && height&.positive?

        width.to_f / height
      end

      def build_text(node)
        return nil unless node.text

        normalized_text = normalize_text(node)
        return nil if normalized_text.nil? || normalized_text.empty?

        style = node.computed_style || node.parent&.computed_style
        TextBox.new(normalized_text, style)
      end

      def normalize_text(node)
        text = node.text.to_s.gsub(/[[:space:]]+/, " ")
        return nil if text.empty?

        previous_inline = inline_neighbor?(node, :previous)
        following_inline = inline_neighbor?(node, :next)

        if text.strip.empty?
          return " " if previous_inline && following_inline

          return nil
        end

        text = text.lstrip unless previous_inline
        text = text.rstrip unless following_inline

        return nil if text.empty?

        text
      end

      def inline_neighbor?(node, direction)
        sibling = sibling_for(node, direction)

        while sibling
          return true if inline_level_node?(sibling)
          return false if block_level_node?(sibling)

          sibling = sibling_for(sibling, direction)
        end

        false
      end

      def sibling_for(node, direction)
        siblings = node.parent&.children
        return nil unless siblings

        index = siblings.index(node)
        return nil unless index

        if direction == :previous
          (index - 1).downto(0) do |candidate_index|
            candidate = siblings[candidate_index]
            return candidate unless candidate.nil?
          end

          nil
        else
          siblings[(index + 1)..]&.find { |candidate| !candidate.nil? }
        end
      end

      def inline_level_node?(node)
        return false unless node

        if node.element?
          display_for(node, node.computed_style) == "inline"
        else
          !collapsed_whitespace?(node.text)
        end
      end

      def block_level_node?(node)
        return false unless node&.element?

        display = display_for(node, node.computed_style)
        display != "inline" && display != "none"
      end

      def collapsed_whitespace?(text)
        text.to_s.gsub(/[[:space:]]+/, " ").strip.empty?
      end

      def display_for(node, style)
        if style.respond_to?(:explicit_display?) && style.explicit_display?
          style["display"]
        else
          DEFAULT_DISPLAY.fetch(node.tag, style["display"])
        end
      end

      def edge_lengths(style, property)
        values = expanded_values(style[property])

        {
          top: px(style["#{property}-top"] || values[:top]),
          right: px(style["#{property}-right"] || values[:right]),
          bottom: px(style["#{property}-bottom"] || values[:bottom]),
          left: px(style["#{property}-left"] || values[:left])
        }
      end

      def border_edges(style, property, default)
        border = border_shorthand(style["border"])
        edges = expanded_values(style["border-#{property}"])

        {
          top: border_edge(style, :top, property, border, edges, default),
          right: border_edge(style, :right, property, border, edges, default),
          bottom: border_edge(style, :bottom, property, border, edges, default),
          left: border_edge(style, :left, property, border, edges, default)
        }
      end

      def border_edge(style, side, property, border, edges, default)
        side_border = border_shorthand(style["border-#{side}"])

        style["border-#{side}-#{property}"] ||
          side_border[property] ||
          edges[side] ||
          border[property] ||
          default
      end

      def expanded_values(value)
        CSS::Values.expanded_edges(value)
      end

      def border_shorthand(value)
        split_tokens(value).each_with_object({}) do |token, parsed|
          if border_width?(token)
            parsed["width"] ||= token
          elsif border_style?(token)
            parsed["style"] ||= token
          else
            parsed["color"] ||= token
          end
        end
      end

      def background_color(style)
        style["background-color"] || background_shorthand_color(style["background"])
      end

      def background_shorthand_color(value)
        split_tokens(value).find { |token| color_token?(token) }
      end

      def flex_values(style)
        shorthand = flex_shorthand(style["flex"])
        row_gap, column_gap = gap_values(style)

        {
          direction: style["flex-direction"] || flex_flow(style)[:direction] || "row",
          wrap: style["flex-wrap"] || flex_flow(style)[:wrap] || "nowrap",
          justify_content: style["justify-content"] || "flex-start",
          align_items: style["align-items"] || "stretch",
          row_gap: row_gap,
          column_gap: column_gap,
          grow: number(style["flex-grow"] || shorthand[:grow], 0),
          shrink: number(style["flex-shrink"] || shorthand[:shrink], 1),
          basis: style["flex-basis"] || shorthand[:basis] || "auto"
        }
      end

      def flex_shorthand(value)
        tokens = split_tokens(value)
        return {} if tokens.empty?

        case tokens.join(" ")
        when "none"
          {grow: 0, shrink: 0, basis: "auto"}
        when "auto"
          {grow: 1, shrink: 1, basis: "auto"}
        when "initial"
          {grow: 0, shrink: 1, basis: "auto"}
        else
          numbers = tokens.select { |token| numeric?(token) }
          basis = tokens.find { |token| !numeric?(token) }

          {
            grow: numbers[0] || 1,
            shrink: numbers[1] || 1,
            basis: basis || (numbers.any? ? "0px" : "auto")
          }
        end
      end

      def flex_flow(style)
        split_tokens(style["flex-flow"]).each_with_object({}) do |token, parsed|
          if %w[row row-reverse column column-reverse].include?(token)
            parsed[:direction] = token
          elsif %w[nowrap wrap wrap-reverse].include?(token)
            parsed[:wrap] = token
          end
        end
      end

      def gap_values(style)
        values = split_tokens(style["gap"])
        row = values[0]
        column = values[1] || values[0]

        [
          px(style["row-gap"] || row),
          px(style["column-gap"] || column)
        ]
      end

      def px(value)
        return 0 unless value

        raw = value.to_s.strip
        return 0 if raw.empty? || raw == "auto"
        return 1 if raw == "thin"
        return 3 if raw == "medium"
        return 5 if raw == "thick"

        raw.delete_suffix("px").to_f
      end

      def color(value)
        parsed = SilkLayout::CSS::Color.parse(value)
        return nil unless parsed

        parsed.to_sym
      end

      def number(value, default)
        return default if value.nil?

        raw = value.to_s.strip
        return default if raw.empty?

        raw.to_f
      end

      def split_tokens(value)
        CSS::Values.split_tokens(value)
      end

      def numeric?(value)
        value.to_s.match?(/\A[-+]?\d*\.?\d+\z/)
      end

      def border_width?(value)
        value.to_s.match?(/\A[-+]?\d*\.?\d+(?:px)?\z/) || %w[thin medium thick].include?(value.to_s)
      end

      def border_style?(value)
        %w[
          none
          hidden
          dotted
          dashed
          solid
          double
          groove
          ridge
          inset
          outset
        ].include?(value.to_s)
      end

      def color_token?(value)
        raw = value.to_s.strip
        return false if raw.empty?
        return true if SilkLayout::CSS::Color.parse(raw)
        return false if %w[none inherit initial unset].include?(raw)

        !border_width?(raw) && !border_style?(raw) && !raw.include?("(") && !raw.include?("/")
      end
    end
  end
end
