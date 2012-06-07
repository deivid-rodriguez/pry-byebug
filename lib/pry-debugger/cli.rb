# Pry's new plugin loading system ensures this file runs before pry-remote. So
# attempting to load everything directly from lib/pry-debugger.rb and
# referencing that here causes a circular dependency when running
# bin/pry-remote.
#
# So delay loading our monkey-patch to when someone explicity does a:
#
#   require 'pry-debugger'
#
# Load everything else here.
#

require 'pry-debugger/base'
require 'pry-debugger/pry_ext'
require 'pry-debugger/commands'
