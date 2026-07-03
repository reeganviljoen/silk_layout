# frozen_string_literal: true

require_relative "../test_helper"

class PainterColorTest < Minitest::Test
  class FakeCanvas
    attr_reader :calls

    def initialize
      @calls = []
    end

    def fill_color(*rgb)
      calls << [:fill_color, rgb]
      self
    end

    def rectangle(*args)
      calls << [:rectangle, args]
      Shape.new(self)
    end

    def move_to(*point)
      calls << [:move_to, point]
      self
    end

    def line_to(*point)
      calls << [:line_to, point]
      self
    end

    def close_subpath
      calls << [:close_subpath]
      self
    end

    def fill
      calls << [:fill]
      self
    end

    def font(name, size:)
      calls << [:font, name, size]
      self
    end

    def text(value, at:)
      calls << [:text, value, at]
      self
    end

    def image(path, at:, width:, height:)
      calls << [:image, path, at, width, height]
      self
    end

    class Shape
      def initialize(canvas)
        @canvas = canvas
      end

      def fill
        @canvas.fill
      end
    end
  end

  def test_converts_colors_through_shared_parser
    assert_equal [255, 0, 0], SilkLayout::Render::Painter.rgb_color(:red)
    assert_equal [17, 34, 51], SilkLayout::Render::Painter.rgb_color(:"#123")
    assert_equal [10, 20, 30], SilkLayout::Render::Painter.rgb_color(:"rgb(10, 20, 30)")
    assert_equal [0, 128, 0], SilkLayout::Render::Painter.rgb_color(:"hsl(120, 100%, 25%)")
  end

  def test_transparent_and_invalid_colors_do_not_convert_to_rgb
    assert_nil SilkLayout::Render::Painter.rgb_color(:transparent)
    assert_nil SilkLayout::Render::Painter.rgb_color(:unknown)
  end

  def test_sets_black_when_color_is_not_paintable
    canvas = FakeCanvas.new

    assert_same canvas, SilkLayout::Render::Painter.set_color(canvas, :unknown)
    assert_includes canvas.calls, [:fill_color, [0, 0, 0]]
  end

  def test_paints_text_with_default_font_fallbacks
    canvas = FakeCanvas.new
    text = SilkLayout::Layout::TextBox.new("Hello", nil)
    text.x = 12
    text.y = 20

    SilkLayout::Render::Painter.paint_text(canvas, text, 200)

    assert_includes canvas.calls, [:font, "Helvetica", 12.0]
    assert canvas.calls.any? { |call| call[0] == :text && call[1] == "Hello" }
  end

  def test_draws_background_for_paintable_box
    canvas = FakeCanvas.new
    box = block_box(width: 40, height: 20, background_color: :red)

    SilkLayout::Render::Painter.draw_background(canvas, box, 100)

    assert_includes canvas.calls, [:fill_color, [255, 0, 0]]
    assert canvas.calls.any? { |call| call[0] == :rectangle }
  end

  def test_ignores_background_for_anonymous_invalid_or_unset_boxes
    anonymous = SilkLayout::Layout::AnonymousBlockBox.new
    anonymous.background_color = :red

    invalid = block_box(width: 10, height: 10, background_color: :unknown)
    unset = block_box(width: 10, height: 10)

    [anonymous, invalid, unset].each do |box|
      canvas = FakeCanvas.new
      SilkLayout::Render::Painter.draw_background(canvas, box, 100)
      assert_empty canvas.calls
    end
  end

  def test_paints_local_image_when_box_has_positive_content_size
    canvas = FakeCanvas.new
    box = block_box(width: 10, height: 10)
    box.replaced = true
    box.image_resource = SilkLayout::Resource::Image.load(fixture_image_path)

    SilkLayout::Render::Painter.paint_image(canvas, box, 100)

    assert canvas.calls.any? { |call| call[0] == :image && call[1] == box.image_path }
  end

  def test_skips_image_without_path_or_positive_size
    no_path = block_box(width: 10, height: 10)
    no_path.replaced = true

    zero_size = block_box(width: 0, height: 10)
    zero_size.replaced = true
    zero_size.image_resource = SilkLayout::Resource::Image.load(fixture_image_path)

    [no_path, zero_size].each do |box|
      canvas = FakeCanvas.new
      SilkLayout::Render::Painter.paint_image(canvas, box, 100)
      assert_empty canvas.calls
    end
  end

  def test_draws_uniform_borders_for_each_side
    canvas = FakeCanvas.new
    box = block_box(width: 20, height: 10)
    box.has_border = true
    box.border = {top: 1, right: 2, bottom: 3, left: 4}
    box.border_color = {top: :blue, right: :blue, bottom: :blue, left: :blue}

    SilkLayout::Render::Painter.draw_borders(canvas, box, 100)

    rectangles = canvas.calls.count { |call| call[0] == :rectangle }
    assert_equal 4, rectangles
  end

  def test_draws_multicolor_border_edges_and_corners
    canvas = FakeCanvas.new
    box = block_box(width: 20, height: 10)
    box.has_border = true
    box.border = {top: 2, right: 2, bottom: 2, left: 2}
    box.border_color = {top: :red, right: :blue, bottom: :green, left: :black}

    SilkLayout::Render::Painter.draw_borders(canvas, box, 100)

    assert canvas.calls.any? { |call| call[0] == :move_to }
    assert_operator canvas.calls.count { |call| call[0] == :rectangle }, :>=, 4
  end

  def test_draw_corner_handles_empty_same_color_and_split_color_corners
    empty_canvas = FakeCanvas.new
    SilkLayout::Render::Painter.draw_corner(empty_canvas, 0, 0, 0, 1, :red, :blue, :top_left)
    assert_empty empty_canvas.calls

    same_canvas = FakeCanvas.new
    SilkLayout::Render::Painter.draw_corner(same_canvas, 0, 0, 1, 1, :red, :red, :top_left)
    assert same_canvas.calls.any? { |call| call[0] == :rectangle }

    %i[top_left top_right bottom_left bottom_right].each do |kind|
      canvas = FakeCanvas.new
      SilkLayout::Render::Painter.draw_corner(canvas, 0, 0, 1, 1, :red, :blue, kind)
      assert_equal 2, canvas.calls.count { |call| call[0] == :close_subpath }
    end
  end

  private

  def block_box(width:, height:, background_color: nil)
    box = SilkLayout::Layout::BlockBox.new(nil)
    box.width = width
    box.height = height
    box.background_color = background_color
    box
  end

  def fixture_image_path
    File.expand_path("../fixtures/images/checker.png", __dir__)
  end
end
