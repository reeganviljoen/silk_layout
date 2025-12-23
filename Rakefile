# frozen_string_literal: true

require "rake/testtask"
require "irb"
require_relative "lib/silk_layout"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

desc "Run StandardRB"
task :standard do
  sh "bundle exec standardrb"
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
