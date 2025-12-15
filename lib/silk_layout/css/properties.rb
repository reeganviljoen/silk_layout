# frozen_string_literal: true

module SilkLayout
  module CSS
    module Properties
      INHERITED = %w[
        color
        font-size
        font-family
      ].freeze

      DEFAULTS = {
        "color" => "black",
        "font-size" => "16px",
        "display" => "inline"
      }.freeze
    end
  end
end
