# frozen_string_literal: true

module SilkLayout
  module Layout
    class InlineFormatter
      Fragment = Struct.new(:box, :text, :width, :height, :break_after, :ascender) do
        def whitespace?
          text&.match?(/\A\s+\z/)
        end
      end

      class << self
        def layout(inline_children, available_width, parent_x, parent_y)
          fragments = flatten(inline_children, available_width)
          lines = []
          current_fragments = []
          current_y = parent_y

          fragments.each do |fragment|
            if fragment.break_after
              line = flush_line(current_fragments, parent_x, current_y)
              if line
                lines << line
                current_y += line.height
              end
              current_fragments = []
              next
            end

            if fragment.whitespace? && current_fragments.empty?
              next
            end

            current_width = current_fragments.sum(&:width)
            overflow = !current_fragments.empty? && (current_width + fragment.width) > available_width

            if overflow
              line = flush_line(current_fragments, parent_x, current_y)
              if line
                lines << line
                current_y += line.height
              end
              current_fragments = []
            end

            next if fragment.whitespace? && current_fragments.empty?

            current_fragments << fragment
          end

          line = flush_line(current_fragments, parent_x, current_y)
          lines << line if line
          lines
        end

        private

        def flush_line(fragments, parent_x, parent_y)
          fragments = trim_trailing_whitespace(fragments)
          return if fragments.empty?

          line = LineBox.new
          cursor_x = 0
          baseline = fragments.map { |fragment| fragment_ascender(fragment) }.max || 0
          descent = fragments.map { |fragment| fragment.height - fragment_ascender(fragment) }.max || 0

          fragments.each do |fragment|
            child = fragment.box
            child.x = parent_x + cursor_x
            child.y = parent_y + baseline - fragment_ascender(fragment)
            child.width = fragment.width
            child.height = fragment.height
            cursor_x += child.width
            line.add_child(child)
          end

          line.width = cursor_x
          line.height = baseline + descent
          line.x = parent_x
          line.y = parent_y
          line
        end

        def trim_trailing_whitespace(fragments)
          trimmed = fragments.dup
          trimmed.pop while trimmed.last&.whitespace?
          trimmed
        end

        def flatten(boxes, available_width)
          boxes.flat_map { |box| flatten_box(box, available_width) }
        end

        def flatten_box(box, available_width)
          case box
          when TextBox
            tokenize_text(box)
          when InlineBox
            if box.respond_to?(:replaced?) && box.replaced?
              [replaced_fragment(box, available_width)]
            elsif box.node&.tag == "br"
              [Fragment.new(box: box, break_after: true)]
            else
              flatten(box.children, available_width)
            end
          else
            []
          end
        end

        def replaced_fragment(box, available_width)
          content_width, content_height = replaced_content_size(box, available_width)
          width = content_width + horizontal_box_edges(box)
          height = content_height + vertical_box_edges(box)

          Fragment.new(
            box: box,
            width: width,
            height: height,
            ascender: height
          )
        end

        def replaced_content_size(box, available_width)
          width = resolved_replaced_width(box, available_width)
          height = resolved_replaced_height(box)
          ratio = aspect_ratio(box)

          if width.nil? && height
            width = ratio ? height * ratio : box.width
          elsif height.nil? && width
            height = ratio ? width / ratio : box.height
          end

          [width || box.width, height || box.height].map { |value| [value, 0].max }
        end

        def resolved_replaced_width(box, available_width)
          raw = style_value(box, "width")
          return box.width if raw.nil? || raw == "auto"

          width = CSS::Values.resolve_length(raw, reference: available_width, default: box.width)
          border_box_sizing?(box) ? width - horizontal_box_edges(box) : width
        end

        def resolved_replaced_height(box)
          raw = style_value(box, "height")
          return nil if raw.nil? || raw == "auto"

          height = CSS::Values.resolve_length(raw, default: box.height)
          border_box_sizing?(box) ? height - vertical_box_edges(box) : height
        end

        def aspect_ratio(box)
          image_ratio = box.image_resource&.aspect_ratio
          return image_ratio if image_ratio

          return nil unless box.width.positive? && box.height.positive?

          box.width.to_f / box.height
        end

        def border_box_sizing?(box)
          style_value(box, "box-sizing") == "border-box"
        end

        def horizontal_box_edges(box)
          box.border[:left] + box.border[:right] + box.padding[:left] + box.padding[:right]
        end

        def vertical_box_edges(box)
          box.border[:top] + box.border[:bottom] + box.padding[:top] + box.padding[:bottom]
        end

        def style_value(box, property)
          value = box.node&.computed_style&.[](property)
          return nil if value.to_s.strip.empty?

          value
        end

        def tokenize_text(box)
          box.text.scan(/\s+|\S+/).map do |token|
            fragment_box = box.clone_with_text(token)
            Fragment.new(
              box: fragment_box,
              text: token,
              width: measure_text(fragment_box),
              height: fragment_box.line_height
            )
          end
        end

        def measure_text(box)
          SilkLayout::Render::FontLibrary.measure_text(
            box.text,
            font_size: box.font_size,
            font_family: box.font_family,
            font_weight: box.font_weight,
            font_style: box.font_style
          )
        end

        def fragment_ascender(fragment)
          fragment.ascender || (fragment.box.is_a?(TextBox) ? fragment.box.ascender : fragment.height)
        end
      end
    end
  end
end
