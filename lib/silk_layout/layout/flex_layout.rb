# frozen_string_literal: true

module SilkLayout
  module Layout
    class FlexLayout
      Item = Struct.new(
        :box,
        :base_content,
        :target_content,
        :outer_main,
        :line
      )

      Line = Struct.new(:items, :cross_size, :main_size)

      def self.layout(box, context, cursor_y = 0, parent_x = 0, containing_width = nil)
        new(box, context, cursor_y, parent_x, containing_width).layout
      end

      def initialize(box, context, cursor_y, parent_x, containing_width)
        @box = box
        @context = context
        @cursor_y = cursor_y
        @parent_x = parent_x
        @containing_width = containing_width
      end

      def layout
        setup_container

        if column?
          layout_column
        else
          layout_row
        end

        @box.width =
          @content_width +
          @box.padding[:left] + @box.padding[:right] +
          @box.border[:left] + @box.border[:right]

        @box.height =
          @content_height +
          @box.padding[:top] + @box.padding[:bottom] +
          @box.border[:top] + @box.border[:bottom]
      end

      private

      def setup_container
        @box.x = @parent_x + @box.margin[:left]
        @box.y = @cursor_y + @box.margin[:top]

        @content_x = @box.x + @box.border[:left] + @box.padding[:left]
        @content_y = @box.y + @box.border[:top] + @box.padding[:top]

        available_width = @containing_width || @context.width
        @content_width =
          if @box.explicit_width
            @box.width
          else
            available_width -
              @box.margin[:left] - @box.margin[:right] -
              @box.border[:left] - @box.border[:right] -
              @box.padding[:left] - @box.padding[:right]
          end

        @content_width = 0 if @content_width < 0
        @content_height = @box.explicit_height ? @box.height : 0
      end

      def layout_row
        items = @box.children.map { |child| build_row_item(child) }
        items.reverse! if direction == "row-reverse"
        lines = row_lines(items)

        cursor_y = @content_y
        lines.each do |line|
          distribute_row_space(line)
          layout_row_line(line)
          position_row_line(line, cursor_y)
          cursor_y += line.cross_size + row_gap
        end

        used_height = lines.sum(&:cross_size) + row_gap * [lines.length - 1, 0].max
        @content_height = [@content_height, used_height].max
        @content_width = shrink_to_row_width(lines) if inline_flex_without_width?
      end

      def build_row_item(child)
        base = row_base_content(child)
        outer = base + horizontal_edges(child)

        Item.new(
          box: child,
          base_content: base,
          target_content: base,
          outer_main: outer
        )
      end

      def row_lines(items)
        return [Line.new(items: [], cross_size: 0, main_size: 0)] if items.empty?
        return [Line.new(items: items)] unless wrap?

        lines = []
        current = []
        current_width = 0

        items.each do |item|
          next_width = current_width
          next_width += column_gap unless current.empty?
          next_width += item.outer_main

          if current.any? && next_width > @content_width
            lines << Line.new(items: current)
            current = []
            current_width = 0
          end

          current_width += column_gap unless current.empty?
          current_width += item.outer_main
          current << item
        end

        lines << Line.new(items: current) if current.any?
        lines
      end

      def distribute_row_space(line)
        occupied =
          line.items.sum { |item| item.base_content + horizontal_edges(item.box) } +
          column_gap * [line.items.length - 1, 0].max

        free = @content_width - occupied

        if free.positive?
          grow_sum = line.items.sum { |item| item.box.flex[:grow] }
          if grow_sum.positive?
            line.items.each do |item|
              item.target_content =
                item.base_content + (free * item.box.flex[:grow] / grow_sum)
            end
          end
        elsif free.negative?
          shrink_sum = line.items.sum { |item| item.box.flex[:shrink] * item.base_content }
          if shrink_sum.positive?
            line.items.each do |item|
              scaled = item.box.flex[:shrink] * item.base_content
              item.target_content =
                [item.base_content + (free * scaled / shrink_sum), 0].max
            end
          end
        end

        line.main_size =
          line.items.sum { |item| item.target_content + horizontal_edges(item.box) } +
          column_gap * [line.items.length - 1, 0].max
      end

      def layout_row_line(line)
        line.items.each do |item|
          layout_child(
            item.box,
            width: item.target_content,
            height: nil
          )
        end

        line.cross_size =
          line.items.map { |item| item.box.height + vertical_margins(item.box) }.max || 0
        line.cross_size = [line.cross_size, @content_height].max if !wrap? && @box.explicit_height

        if align_items == "stretch"
          line.items.each do |item|
            child = item.box
            next if child.explicit_height

            stretched = line.cross_size - vertical_margins(child)
            child.height = stretched if stretched > child.height
          end
        end
      end

      def position_row_line(line, cursor_y)
        cursor_x = @content_x + justify_offset(line)
        item_gap = justified_gap(line)

        line.items.each do |item|
          child = item.box
          target_x = cursor_x + child.margin[:left]
          target_y = cursor_y + child.margin[:top] + align_offset(child, line.cross_size)

          move_subtree(child, target_x - child.x, target_y - child.y)

          cursor_x += child.width + horizontal_margins(child) + item_gap
        end
      end

      def layout_column
        items = @box.children.map { |child| build_column_item(child) }
        items.reverse! if direction == "column-reverse"
        occupied =
          items.sum { |item| item.base_content + vertical_edges(item.box) } +
          row_gap * [items.length - 1, 0].max

        distribute_column_space(items, occupied)

        cursor_y = @content_y + column_justify_offset(items)
        item_gap = column_justified_gap(items)
        max_width = 0

        items.each do |item|
          child = item.box
          child_width = column_child_width(child)

          layout_child(
            child,
            width: child_width,
            height: item.target_content
          )

          target_x = @content_x + child.margin[:left] + column_align_offset(child)
          target_y = cursor_y + child.margin[:top]
          move_subtree(child, target_x - child.x, target_y - child.y)

          cursor_y += child.height + vertical_margins(child) + item_gap
          max_width = [max_width, child.width + horizontal_margins(child)].max
        end

        used_height =
          items.sum { |item| item.box.height + vertical_margins(item.box) } +
          row_gap * [items.length - 1, 0].max

        @content_height = [@content_height, used_height].max
        @content_width = max_width if inline_flex_without_width?
      end

      def build_column_item(child)
        base = column_base_content(child)

        Item.new(
          box: child,
          base_content: base,
          target_content: base,
          outer_main: base + vertical_edges(child)
        )
      end

      def distribute_column_space(items, occupied)
        return unless @box.explicit_height

        free = @content_height - occupied

        if free.positive?
          grow_sum = items.sum { |item| item.box.flex[:grow] }
          if grow_sum.positive?
            items.each do |item|
              item.target_content =
                item.base_content + (free * item.box.flex[:grow] / grow_sum)
            end
          end
        elsif free.negative?
          shrink_sum = items.sum { |item| item.box.flex[:shrink] * item.base_content }
          if shrink_sum.positive?
            items.each do |item|
              scaled = item.box.flex[:shrink] * item.base_content
              item.target_content =
                [item.base_content + (free * scaled / shrink_sum), 0].max
            end
          end
        end
      end

      def layout_child(child, width:, height:)
        child.explicit_width = true
        child.width = [width, 0].max

        if height
          child.explicit_height = true
          child.height = [height, 0].max
        end

        BlockLayout.layout(child, @context, 0, 0, width)
        child.height = [height, 0].max + vertical_box_edges(child) if height
      end

      def row_base_content(child)
        basis = basis_px(child)
        return basis if basis
        return child.width if child.explicit_width

        intrinsic_width(child)
      end

      def column_base_content(child)
        basis = basis_px(child)
        return basis if basis
        return child.height if child.explicit_height

        layout_child(child, width: column_child_width(child), height: nil)
        [child.height - vertical_box_edges(child), 0].max
      end

      def column_child_width(child)
        if align_items == "stretch" && !child.explicit_width
          [@content_width - horizontal_edges(child), 0].max
        elsif child.explicit_width
          child.width
        else
          intrinsic_width(child)
        end
      end

      def basis_px(child)
        basis = child.flex[:basis]
        return nil if basis.nil? || basis == "auto"

        px(basis)
      end

      def intrinsic_width(box)
        return measure_text(box) if box.is_a?(TextBox)
        return box.width if box.explicit_width

        child_widths = box.children.map { |child| intrinsic_width(child) }
        box.is_a?(InlineBox) ? child_widths.sum : (child_widths.max || 0)
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

      def shrink_to_row_width(lines)
        lines.map(&:main_size).max || 0
      end

      def inline_flex_without_width?
        @box.display == "inline-flex" && !@box.explicit_width
      end

      def column?
        %w[column column-reverse].include?(direction)
      end

      def wrap?
        %w[wrap wrap-reverse].include?(@box.flex[:wrap])
      end

      def direction
        @box.flex[:direction]
      end

      def align_items
        @box.flex[:align_items]
      end

      def row_gap
        @box.flex[:row_gap]
      end

      def column_gap
        @box.flex[:column_gap]
      end

      def justify_content
        @box.flex[:justify_content]
      end

      def justify_offset(line)
        free = [@content_width - line.main_size, 0].max

        case justify_content
        when "flex-end", "end", "right"
          free
        when "center"
          free / 2.0
        when "space-around"
          line.items.empty? ? 0 : free / line.items.length / 2.0
        when "space-evenly"
          line.items.empty? ? 0 : free / (line.items.length + 1)
        else
          0
        end
      end

      def justified_gap(line)
        free = [@content_width - line.main_size, 0].max
        base = column_gap

        case justify_content
        when "space-between"
          (line.items.length > 1) ? base + (free / (line.items.length - 1)) : base
        when "space-around"
          line.items.any? ? base + (free / line.items.length) : base
        when "space-evenly"
          line.items.any? ? base + (free / (line.items.length + 1)) : base
        else
          base
        end
      end

      def align_offset(child, line_cross_size)
        free = [line_cross_size - child.height - vertical_margins(child), 0].max

        case align_items
        when "flex-end", "end", "bottom"
          free
        when "center"
          free / 2.0
        else
          0
        end
      end

      def column_justify_offset(items)
        free = [@content_height - column_main_size(items), 0].max

        case justify_content
        when "flex-end", "end", "bottom"
          free
        when "center"
          free / 2.0
        when "space-around"
          items.empty? ? 0 : free / items.length / 2.0
        when "space-evenly"
          items.empty? ? 0 : free / (items.length + 1)
        else
          0
        end
      end

      def column_justified_gap(items)
        free = [@content_height - column_main_size(items), 0].max
        base = row_gap

        case justify_content
        when "space-between"
          (items.length > 1) ? base + (free / (items.length - 1)) : base
        when "space-around"
          items.any? ? base + (free / items.length) : base
        when "space-evenly"
          items.any? ? base + (free / (items.length + 1)) : base
        else
          base
        end
      end

      def column_main_size(items)
        items.sum { |item| item.target_content + vertical_edges(item.box) } +
          row_gap * [items.length - 1, 0].max
      end

      def column_align_offset(child)
        free = [@content_width - child.width - horizontal_margins(child), 0].max

        case align_items
        when "flex-end", "end", "right"
          free
        when "center"
          free / 2.0
        else
          0
        end
      end

      def move_subtree(box, dx, dy)
        box.x += dx
        box.y += dy
        box.children.each { |child| move_subtree(child, dx, dy) }
      end

      def horizontal_edges(box)
        horizontal_margins(box) + box.padding[:left] + box.padding[:right] + box.border[:left] + box.border[:right]
      end

      def vertical_edges(box)
        vertical_margins(box) + box.padding[:top] + box.padding[:bottom] + box.border[:top] + box.border[:bottom]
      end

      def vertical_box_edges(box)
        box.padding[:top] + box.padding[:bottom] + box.border[:top] + box.border[:bottom]
      end

      def horizontal_margins(box)
        box.margin[:left] + box.margin[:right]
      end

      def vertical_margins(box)
        box.margin[:top] + box.margin[:bottom]
      end

      def px(value)
        return 0 unless value

        raw = value.to_s.strip
        return 0 if raw.empty? || raw == "auto"

        raw.delete_suffix("px").to_f
      end
    end
  end
end
