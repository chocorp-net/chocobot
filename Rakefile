# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.requires << 'rubocop-rspec'
  t.verbose = true
  t.fail_on_error = true
  t.options = ['--display-cop-names']
end

task default: %i[test lint]

desc 'Run tests'
task :test do
  RSpec::Core::Runner.run ['spec']
end

desc 'Check the project passes tests'
task :check do
  Rake::Task['test'].invoke
  Rake::Task['rubocop'].invoke
end
