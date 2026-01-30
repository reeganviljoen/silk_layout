# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
require "simplecov-console"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/test/"
  add_filter "/vendor/"

  track_files "lib/**/*.rb"

  minimum_coverage 80
end

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]

SimpleCov.at_exit do
  SimpleCov.result.format!

  covered = SimpleCov.result.covered_percent.round(2)

  puts "\n📊 Coverage: #{covered}%"

  if covered < (ENV["COVERAGE_MIN"] || 80).to_f
    abort "❌ Coverage below threshold"
  end
end

require "silk_layout"
require "minitest/autorun"
