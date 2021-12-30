# frozen_string_literal: true

require 'rubocop/rake_task'

task default: %i[test lint]

desc 'Run tests'
task(:test) do
  system('rspec')
end

desc 'Run rubocop'
task :lint do
  system('rubocop')
end

desc 'Run rubocop and correct some mistakes'
task :fix_lint do
  system('rubocop -a')
end
