# frozen_string_literal: true

module SilkLayout
  autoload :VERSION, "silk_layout/version"
  autoload :CLI, "silk_layout/cli"
  autoload :Document, "silk_layout/document"

  module HTML
    autoload :Parser, "silk_layout/html/parser"
    autoload :Node, "silk_layout/html/node"
  end

  module CSS
    autoload :Parser, "silk_layout/css/parser"
    autoload :Cascade, "silk_layout/css/cascade"
    autoload :ComputedStyle, "silk_layout/css/computed_style"
    autoload :Rule, "silk_layout/css/rule"
    autoload :Selector, "silk_layout/css/selector"
    autoload :Properties, "silk_layout/css/properties"
  end

  module Layout
    autoload :Box, "silk_layout/layout/box"
    autoload :Block, "silk_layout/layout/block"
    autoload :Inline, "silk_layout/layout/inline"
    autoload :Page, "silk_layout/layout/page"
    autoload :Paginator, "silk_layout/layout/paginator"
    autoload :Builder, "silk_layout/layout/builder"
    autoload :BoxBuilder, "silk_layout/layout/box_builder"
  end

  module Render
    autoload :PDF, "silk_layout/render/pdf"
    autoload :Canvas, "silk_layout/render/canvas"
  end

  module Util
    autoload :Measurements, "silk_layout/util/measurements"
  end
end
