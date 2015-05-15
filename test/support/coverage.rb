#
# Starts code coverage tracking. If running on CI, use codeclimate's wrapper to
# report results to them.
#
def start_coverage_tracking
  require 'simplecov'
  SimpleCov.add_filter 'test'

  conf = if ENV['CI']
           require 'codeclimate-test-reporter'
           CodeClimate::TestReporter.configuration.profile
         end

  SimpleCov.start conf
end

start_coverage_tracking
