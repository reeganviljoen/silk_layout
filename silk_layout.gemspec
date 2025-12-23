# frozen_string_literal: true

require_relative "lib/silk_layout/version"

Gem::Specification.new do |spec|
  spec.name = "silk_layout"
  spec.version = SilkLayout::VERSION
  spec.authors = ["Your Name"]
  spec.summary = "Ruby-native HTML/CSS layout and PDF engine"
  spec.description = "SilkLayout is a long-term Ruby reimplementation of WeasyPrint"
  spec.files = Dir["lib/**/*", "test/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "crass"
  spec.add_dependency "hexapdf"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "ferrum"
  spec.add_development_dependency "chunky_png"
  spec.add_development_dependency "irb"
end
