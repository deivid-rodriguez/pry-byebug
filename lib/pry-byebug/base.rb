#
# Main container module for Pry-Byebug functionality
#
module PryByebug
  # Reference to currently running pry-remote server. Used by the processor.
  attr_accessor :current_remote_server
end
