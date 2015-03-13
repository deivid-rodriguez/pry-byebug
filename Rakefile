require 'bundler/gem_tasks'

require 'rake/testtask'

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.ruby_opts += ['-w']
  t.pattern = 'test/**/*_test.rb'
end

require 'rubocop/rake_task'

desc 'Run RuboCop'
task(:rubocop) { RuboCop::RakeTask.new }

task default: [:test, :rubocop]
