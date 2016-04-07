require 'bundler/gem_tasks'

require 'rake/testtask'

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.warning = false
  t.verbose = true
  t.pattern = 'test/**/*_test.rb'
end

desc 'Run overcommit hooks manually'
task :overcommit do
  exit 1 unless system('bundle exec overcommit --run')
end

desc 'Sign overcommit hooks'
task :sign_hooks do
  system('bundle exec overcommit --sign')
end

task default: %i(test overcommit)
