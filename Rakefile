# frozen_string_literal: true

desc 'Run all tasks'
task :all do
  Rake::Task['rubocop'].execute
  Rake::Task['test'].execute
end

desc 'Run rubocop'
task :rubocop do
  sh 'rubocop'
end

desc 'Run unit tests'
task :test do
  ruby 'test/master_tree_test.rb'
end

task default: :all
