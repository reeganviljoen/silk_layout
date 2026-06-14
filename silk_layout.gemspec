# frozen_string_literal: true

require_relative "lib/silk_layout/version"

Gem::Specification.new do |spec|
  spec.name = "silk_layout"
  spec.version = SilkLayout::VERSION
  spec.authors = ["Reegan Viljoen"]
  spec.summary = "Ruby-native HTML/CSS layout and PDF engine"
  spec.description = "SilkLayout is a Ruby-native HTML/CSS layout engine for rendering documents to PDF."
  spec.license = "MIT"
  spec.homepage = "https://github.com/reeganviljoen/silk_layout"
  spec.required_ruby_version = ">= 3.2"
  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/reeganviljoen/silk_layout/issues",
    "changelog_uri" => "https://github.com/reeganviljoen/silk_layout/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://reeganviljoen.github.io/silk_layout/",
    "source_code_uri" => "https://github.com/reeganviljoen/silk_layout"
  }
  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "crass"
  spec.add_dependency "hexapdf"
  spec.add_dependency "nokogiri"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "ferrum"
  spec.add_development_dependency "chunky_png"
  spec.add_development_dependency "irb"
  spec.add_development_dependency "parallel", "< 2.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-console"
end
