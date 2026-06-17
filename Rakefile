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

namespace :package do
  desc "Build, install, and require the gem from a temporary GEM_HOME"
  task smoke: :build do
    require "tmpdir"

    version = SilkLayout::VERSION
    gem_file = File.expand_path("pkg/silk_layout-#{version}.gem", __dir__)

    raise "Expected built gem at #{gem_file}" unless File.file?(gem_file)

    base_gem_path = Gem.path

    Dir.mktmpdir("silk_layout_package_smoke") do |dir|
      gem_home = File.join(dir, "gems")
      bindir = File.join(dir, "bin")
      smoke_env = {
        "BUNDLE_BIN_PATH" => nil,
        "BUNDLE_GEMFILE" => nil,
        "BUNDLER_VERSION" => nil,
        "GEM_HOME" => gem_home,
        "GEM_PATH" => ([gem_home] + base_gem_path).uniq.join(File::PATH_SEPARATOR),
        "RUBYLIB" => nil,
        "RUBYOPT" => nil
      }

      install_cmd = [
        Gem.ruby,
        "-S",
        "gem",
        "install",
        gem_file,
        "--no-document",
        "--ignore-dependencies",
        "--install-dir",
        gem_home,
        "--bindir",
        bindir
      ]

      smoke_script = <<~RUBY
        require "tmpdir"

        gem "silk_layout", "#{version}"
        require "silk_layout"

        Dir.mktmpdir("silk_layout_package_output") do |output_dir|
          output = File.join(output_dir, "smoke.pdf")
          SilkLayout.render_document("<!doctype html><p>package smoke</p>", output)
          abort "expected \#{output} to be non-empty" unless File.file?(output) && File.size(output).positive?
        end
      RUBY

      sh smoke_env, *install_cmd
      sh smoke_env, Gem.ruby, "-e", smoke_script
    end
  end
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
