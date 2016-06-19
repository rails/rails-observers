#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new("test:regular") do |t|
  t.libs = ["test"]
  t.pattern = "test/*_test.rb"
  t.ruby_opts = ['-w']
end

Rake::TestTask.new("test:generators") do |t|
  t.libs = ["test"]
  t.pattern = "test/generators/*_test.rb"
  t.ruby_opts = ['-w']
end

task :default => :test
task :test => ['test:regular', 'test:generators']
