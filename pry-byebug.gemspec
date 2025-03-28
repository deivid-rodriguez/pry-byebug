# frozen_string_literal: true

require File.dirname(__FILE__) + "/lib/pry-byebug/version"

Gem::Specification.new do |gem|
  gem.name = "pry-byebug"
  gem.version = PryByebug::VERSION
  gem.authors = ["David Rodríguez", "Gopal Patel"]
  gem.email = "deivid.rodriguez@gmail.com"
  gem.license = "MIT"
  gem.homepage = "https://github.com/deivid-rodriguez/pry-byebug"
  gem.summary = "Fast debugging with Pry."
  gem.description = "Combine 'pry' with 'byebug'. Adds 'step', 'next', 'finish',
    'continue' and 'break' commands to control execution."

  gem.files = Dir["lib/**/*.rb", "LICENSE"]
  gem.extra_rdoc_files = %w[CHANGELOG.md README.md]
  gem.require_path = "lib"
  gem.executables = []

  gem.metadata = {
    "bug_tracker_uri" => "https://github.com/deivid-rodriguez/pry-byebug/issues",
    "changelog_uri" => "https://github.com/deivid-rodriguez/pry-byebug/blob/HEAD/CHANGELOG.md",
    "source_code_uri" => "https://github.com/deivid-rodriguez/pry-byebug",
    "funding_uri" => "https://liberapay.com/pry-byebug"
  }

  # Dependencies
  gem.required_ruby_version = ">= 3.1.0"

  gem.add_runtime_dependency "byebug", "~> 12.0"
  gem.add_runtime_dependency "pry", ">= 0.13", "< 0.16"
end
