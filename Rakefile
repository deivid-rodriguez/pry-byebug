require "bundler/gem_tasks"
require "chandler/tasks"
require "rake/testtask"

#
# Add chandler as a prerequisite for `rake release`
#
task "release:rubygem_push" => "chandler:push"

desc "Run tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.warning = false
  t.verbose = true
  t.pattern = "test/**/*_test.rb"
end

task default: :test
