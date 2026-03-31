# frozen_string_literal: true

module SilkLayout
  module Layout
    class InlineFormatter
      Fragment = Struct.new(:box, :text, :width, :height, :break_after, keyword_init: true) do
        def whitespace?
          text&.match?(/\A\s+\z/)
        end
      end

      class << self
        def layout(inline_children, available_width, parent_x, parent_y)
          fragments = flatten(inline_children)
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
          baseline = fragments.map { |fragment| fragment.box.ascender if fragment.box.is_a?(TextBox) }.compact.max || 0

          fragments.each do |fragment|
            child = fragment.box
            child.x = parent_x + cursor_x
            child.y = parent_y + baseline - child.ascender
            child.width = fragment.width
            child.height = fragment.height
            cursor_x += child.width
            line.add_child(child)
          end

          line.width = cursor_x
          line.height = fragments.map(&:height).max || 0
          line.x = parent_x
          line.y = parent_y
          line
        end

        def trim_trailing_whitespace(fragments)
          trimmed = fragments.dup
          trimmed.pop while trimmed.last&.whitespace?
          trimmed
        end

        def flatten(boxes)
          boxes.flat_map { |box| flatten_box(box) }
        end

        def flatten_box(box)
          case box
          when TextBox
            tokenize_text(box)
          when InlineBox
            if box.node&.tag == "br"
              [Fragment.new(box: box, break_after: true)]
            else
              flatten(box.children)
            end
          else
            []
          end
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
      end
    end
  end
end
