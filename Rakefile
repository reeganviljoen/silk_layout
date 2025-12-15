# frozen_string_literal: true

require "rake/testtask"

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

task default: %i[test standard]
