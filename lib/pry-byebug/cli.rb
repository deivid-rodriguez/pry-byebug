# Pry's new plugin loading system ensures this file runs before pry-remote. So
# attempting to load everything directly from lib/pry-byebug.rb and
# referencing that here causes a circular dependency when running
# bin/pry-remote.
#
# So delay loading our monkey-patch to when someone explicity does a:
#
#   require 'pry-byebug'
#
# Load everything else here.
#

require 'pry-byebug/base'
require 'pry-byebug/pry_ext'
require 'pry-byebug/commands'
