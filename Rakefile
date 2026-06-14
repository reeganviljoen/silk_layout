# frozen_string_literal: true

require "rake/testtask"
require "bundler/gem_tasks"
require "irb"
require_relative "lib/silk_layout"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
end

desc "Run StandardRB"
task :standard do
  sh "bundle exec standardrb"
end

namespace :coverage do
  task :report do
    require "simplecov"
    require "simplecov-console"

    SimpleCov.minimum_coverage 100

    SimpleCov.collate Dir["{coverage,simplecov-resultset-*}/.resultset.json"], "rails" do
      formatter SimpleCov::Formatter::Console
    end
  end
end

namespace :dev do
  desc "Open an IRB console with SilkLayout loaded"
  task :console do
    puts "Loading SilkLayout IRB console…"
    ARGV.clear
    IRB.start
  end
end

task default: %i[test standard]
