# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
require "simplecov-console"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "lib/silk_layout/version.rb"

  track_files "lib/**/*.rb"

  minimum_coverage 95
end

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]

SimpleCov.at_exit do
  SimpleCov.result.format!

  covered = SimpleCov.result.covered_percent.round(2)

  puts "\nCoverage: #{covered}%"

  if covered < (ENV["COVERAGE_MIN"] || 95).to_f
    abort "Coverage below threshold"
  end
end

require "silk_layout"
require "minitest/autorun"
