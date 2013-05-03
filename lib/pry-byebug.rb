require 'pry-byebug/cli'

# Load pry-remote monkey patches if pry-remote's available
begin
  require 'pry-byebug/pry_remote_ext'
rescue LoadError
end
