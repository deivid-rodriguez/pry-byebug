require 'pry-debugger/cli'

# Load pry-remote monkey patches if pry-remote's available
begin
  require 'pry-debugger/pry_remote_ext'
rescue LoadError
end
