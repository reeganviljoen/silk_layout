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

      # HTML element-specific defaults (user agent stylesheet)
      # These match browser default behavior for common HTML elements
      HTML_ELEMENT_DEFAULTS = {
        "div" => {
          "display" => "block"
        },
        "p" => {
          "display" => "block"
        },
        "h1" => {
          "display" => "block",
          "font-size" => "2em",
          "margin-top" => "0.67em",
          "margin-bottom" => "0.67em",
          "font-weight" => "bold"
        },
        "h2" => {
          "display" => "block",
          "font-size" => "1.5em",
          "margin-top" => "0.83em",
          "margin-bottom" => "0.83em",
          "font-weight" => "bold"
        },
        "h3" => {
          "display" => "block",
          "font-size" => "1.17em",
          "margin-top" => "1em",
          "margin-bottom" => "1em",
          "font-weight" => "bold"
        },
        "ul" => {
          "display" => "block",
          "margin-top" => "1em",
          "margin-bottom" => "1em",
          "padding-left" => "40px"
        },
        "ol" => {
          "display" => "block",
          "margin-top" => "1em",
          "margin-bottom" => "1em",
          "padding-left" => "40px"
        },
        "li" => {
          "display" => "list-item"
        },
        "span" => {
          "display" => "inline"
        },
        "strong" => {
          "display" => "inline",
          "font-weight" => "bold"
        },
        "em" => {
          "display" => "inline",
          "font-style" => "italic"
        }
      }.freeze
    end
  end
end
