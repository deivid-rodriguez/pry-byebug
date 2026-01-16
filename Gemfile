# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "rake", "~> 13.0"

  gem "chandler", "0.9.0"

  # To workaround octokit warning. Can be removed once
  # https://github.com/octokit/octokit.rb/pull/1706 is released
  gem "faraday-retry"

  gem "mdl", "0.14.0"
  gem "minitest", "~> 5.14"
  gem "minitest-bisect", "~> 1.5"
  gem "rubocop", "~> 1.0"
end
