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
          child_box = build_box(child)
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
        return nil unless node.element?
        display = node.computed_style["display"]

        case display
        when "block"
          BlockBox.new(node)
        when "inline"
          InlineBox.new(node)
        else
          BlockBox.new(node)
        end
      end

      private_class_method :build_box, :create_box
    end
  end
end
