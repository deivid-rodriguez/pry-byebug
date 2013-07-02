require 'pry'
require 'pry-byebug/processor'

class << Pry
  alias_method :start_without_pry_byebug, :start
  attr_reader :processor

  def start_with_pry_byebug(target = TOPLEVEL_BINDING, options = {})
    @processor ||= PryByebug::Processor.new

    if target.is_a?(Binding) && PryByebug.check_file_context(target)
      # Wrap the processor around the usual Pry.start to catch navigation
      # commands.
      @processor.run(true) do
        start_without_pry_byebug(target, options)
      end
    else
      # No need for the tracer unless we have a file context to step through
      start_without_pry_byebug(target, options)
    end
  end
  alias_method :start, :start_with_pry_byebug
end

if Pry.plugins.include?("stack_explorer")
  Pry.config.hooks.add_hook(:before_session, :debugger_frame_manager, PryDebugger::BeforeSessionHook.new)
  # move default to the back of before_session
  default = Pry.config.hooks.get_hook(:before_session, :default)
  Pry.config.hooks.delete_hook(:before_session, :default)
  Pry.config.hooks.add_hook(:before_session, :default, default)
end
