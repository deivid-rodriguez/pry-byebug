require 'pry-remote'

module PryRemote
  class Server
    # Override the call to Pry.start to save off current Server, and not
    # teardown the server right after Pry.start finishes.
    def run
      if PryDebugger.current_remote_server
        raise 'Already running a pry-remote session!'
      else
        PryDebugger.current_remote_server = self
      end

      setup
      Pry.start @object, {
        :input  => client.input_proxy,
        :output => client.output
      }
    end

    # Override to reset our saved global current server session.
    alias_method :teardown_without_pry_debugger, :teardown
    def teardown_with_pry_debugger
      return if @torn

      teardown_without_pry_debugger
      PryDebugger.current_remote_server = nil
      @torn = true
    end
    alias_method :teardown, :teardown_with_pry_debugger
  end
end

# Ensure cleanup when a program finishes without another break. For example,
# 'next' on the last line of a program won't hit PryDebugger::Processor#run,
# which normally handles cleanup.
at_exit do
  if PryDebugger.current_remote_server
    PryDebugger.current_remote_server.teardown
  end
end
