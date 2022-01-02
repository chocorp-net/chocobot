# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec'

task default: %i[test lint]

desc 'Run tests'
task :test do
  RSpec::Core::Runner.run ['spec']
end

desc 'Run rubocop'
task :lint do
  system('rubocop')
end

desc 'Run rubocop and correct some mistakes'
task :fix_lint do
  system('rubocop -a')
end

desc 'Check the project passes tests'
task :check do
  Rake::Task['test'].invoke
  Rake::Task['lint'].invoke
end
