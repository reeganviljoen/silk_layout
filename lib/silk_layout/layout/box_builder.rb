# frozen_string_literal: true

module SilkLayout
  module Layout
    class BoxBuilder
      def self.build(dom_root)
        build_box(dom_root)
      end

      def self.build_box(node)
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


      def self.create_box(node)
        return nil unless node
        return nil unless node.respond_to?(:element?) && node.element?

        box =
          case node.computed_style["display"]
          when "block"
            BlockBox.new(node)
          when "inline"
            InlineBox.new(node)
          else
            BlockBox.new(node)
          end

        style = node.computed_style

        # ----------------------------
        # Width handling
        # ----------------------------
        if style.respond_to?(:explicit_width?) && style.explicit_width?
          box.explicit_width = true
          box.width = px(style["width"])
        else
          box.explicit_width = false
        end

        # ----------------------------
        # Margin
        # ----------------------------
        box.margin = {
          top:    px(style["margin-top"]    || style["margin"]),
          right:  px(style["margin-right"]  || style["margin"]),
          bottom: px(style["margin-bottom"] || style["margin"]),
          left:   px(style["margin-left"]   || style["margin"])
        }

        # ----------------------------
        # Padding
        # ----------------------------
        box.padding = {
          top:    px(style["padding-top"]    || style["padding"]),
          right:  px(style["padding-right"]  || style["padding"]),
          bottom: px(style["padding-bottom"] || style["padding"]),
          left:   px(style["padding-left"]   || style["padding"])
        }

        # ----------------------------
        # Border widths
        # ----------------------------
        box.border = {
          top:    px(style["border-top-width"]    || style["border-width"]),
          right:  px(style["border-right-width"]  || style["border-width"]),
          bottom: px(style["border-bottom-width"] || style["border-width"]),
          left:   px(style["border-left-width"]   || style["border-width"])
        }

        # Border exists if ANY side has width
        box.has_border = box.border.values.any? { |v| v > 0 }

        # ----------------------------
        # Border colors
        # ----------------------------
        # CSS default: black if border exists and color not specified
        default_color = box.has_border ? nil : nil

        box.border_color = {
          top:    color(style["border-top-color"]    || style["border-color"]) || default_color,
          right:  color(style["border-right-color"]  || style["border-color"]) || default_color,
          bottom: color(style["border-bottom-color"] || style["border-color"]) || default_color,
          left:   color(style["border-left-color"]   || style["border-color"]) || default_color
        }

        box
      end

      def self.build_text(node)
        return nil unless node.text

        parent_style = node.computed_style
        TextBox.new(node.text, parent_style)
      end

      def self.px(value)
        return 0 unless value
        value.to_s.delete_suffix("px").to_i
      end
      
      def self.color(value)
        return nil unless value
        value.to_sym
      end

      private_class_method :build_box, :create_box
    end
  end
end
