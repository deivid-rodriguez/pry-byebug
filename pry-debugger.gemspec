# -*- encoding: utf-8 -*-

require File.expand_path('../lib/pry-debugger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'pry-debugger'
  gem.version       = PryDebugger::VERSION
  gem.author        = 'Gopal Patel'
  gem.email         = 'nixme@stillhope.com'
  gem.license       = 'MIT'
  gem.homepage      = 'https://github.com/nixme/pry-debugger'
  gem.summary       = 'Fast debugging with Pry.'
  gem.description   = "Combine 'pry' with 'debugger'. Adds 'step', 'next', and 'continue' commands to control execution."

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  # Dependencies
  gem.required_ruby_version = '>= 1.9.2'
  gem.add_runtime_dependency 'pry', '~> 0.9.10'
  gem.add_runtime_dependency 'debugger', '~> 1.3'
  gem.add_development_dependency 'pry-remote', '~> 0.1.6'
end
