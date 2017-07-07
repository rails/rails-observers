#!/usr/bin/env rake
require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
Bundler.require(:default, :development, :test)

require 'rake/testtask'
Rake.load_rakefile 'rails/tasks/annotations.rake'

# Simplify debugging greatly by not running tests
# in separate process
namespace :test do
  desc 'Regular unit tests'
  task :regular do
    $:.unshift File.expand_path('../test', __FILE__)
    $VERBOSE = true
    Dir['test/*_test.rb'].each do |file|
      Object.instance_exec(file) do |test|
        require_relative(test)
      end
    end
  end

  desc 'Test generators'
  task :generators do
    $:.unshift File.expand_path('../test', __FILE__)
    $VERBOSE = true
    Dir['test/generators/*_test.rb'].each do |file|
      Object.instance_exec(file) do |test|
        require_relative(test)
      end
    end
  end

  desc 'All unit tests'
  task :all => [ :regular, :generators ]
end

task :test => 'test:all'
task :default => :test
