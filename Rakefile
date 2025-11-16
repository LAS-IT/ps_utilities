require "rspec/core/rake_task"
require 'bundler/gem_helper'

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

task :default => :spec
