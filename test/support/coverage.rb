# frozen_string_literal: true

#
# Starts code coverage tracking.
#
def start_coverage_tracking
  require "simplecov"
  SimpleCov.add_filter "test"
  SimpleCov.start
end

start_coverage_tracking
