require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
    a.push('--require spec_helper')
  end.join(' ')
end

desc 'Run all tests'
task :test => [:unit]

task :default => [:test]