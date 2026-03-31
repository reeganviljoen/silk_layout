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
          when "inline"
            InlineBox.new(node)
          else
            BlockBox.new(node)
          end

        if style.respond_to?(:explicit_width?) && style.explicit_width?
          box.explicit_width = true
          box.width = px(style["width"])
        else
          box.explicit_width = false
        end

        box.margin = {
          top: px(style["margin-top"] || style["margin"]),
          right: px(style["margin-right"] || style["margin"]),
          bottom: px(style["margin-bottom"] || style["margin"]),
          left: px(style["margin-left"] || style["margin"])
        }

        box.padding = {
          top: px(style["padding-top"] || style["padding"]),
          right: px(style["padding-right"] || style["padding"]),
          bottom: px(style["padding-bottom"] || style["padding"]),
          left: px(style["padding-left"] || style["padding"])
        }

        border_styles = {
          top: style["border-top-style"] || style["border-style"] || "none",
          right: style["border-right-style"] || style["border-style"] || "none",
          bottom: style["border-bottom-style"] || style["border-style"] || "none",
          left: style["border-left-style"] || style["border-style"] || "none"
        }

        box.border = {
          top: px(style["border-top-width"] || style["border-width"]),
          right: px(style["border-right-width"] || style["border-width"]),
          bottom: px(style["border-bottom-width"] || style["border-width"]),
          left: px(style["border-left-width"] || style["border-width"])
        }

        box.border.each_key do |side|
          box.border[side] = 0 if border_styles[side] == "none"
        end

        box.has_border = box.border.values.any? { |value| value > 0 }

        default_color = box.has_border ? :black : nil

        box.border_color = {
          top: color(style["border-top-color"] || style["border-color"]) || default_color,
          right: color(style["border-right-color"] || style["border-color"]) || default_color,
          bottom: color(style["border-bottom-color"] || style["border-color"]) || default_color,
          left: color(style["border-left-color"] || style["border-color"]) || default_color
        }

        box
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
          siblings[0...index].reverse_each.find { |candidate| !candidate.nil? }
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

      def px(value)
        return 0 unless value

        value.to_s.delete_suffix("px").to_i
      end

      def color(value)
        return nil unless value

        value.to_sym
      end
    end
  end
end
