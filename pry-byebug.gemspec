# -*- encoding: utf-8 -*-

require File.expand_path('../lib/pry-byebug/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'pry-byebug'
  gem.version       = PryByebug::VERSION
  gem.author        = 'Gopal Patel'
  gem.email         = 'nixme@stillhope.com'
  gem.license       = 'MIT'
  gem.homepage      = 'https://github.com/deivid-rodriguez/pry-byebug'
  gem.summary       = 'Fast debugging with Pry.'
  gem.description   = "Combine 'pry' with 'byebug'. Adds 'step', 'next', and " \
                      "'continue' commands to control execution."
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  # Dependencies
  gem.required_ruby_version = '>= 2.0.0'
  gem.add_runtime_dependency 'pry', '>= 0.9.10'
  gem.add_runtime_dependency 'byebug', '~> 1.1.1'
  gem.add_development_dependency 'bundler', '~> 1.3.5'
end
