require 'byebug/processors/pry_processor'

class << Pry
  alias_method :start_without_pry_byebug, :start
  attr_reader :processor

  def start_with_pry_byebug(target = TOPLEVEL_BINDING, options = {})
    @processor ||= Byebug::PryProcessor.new

    if target.is_a?(Binding) && PryByebug.file_context?(target)
      # Wrap processor around the usual Pry.start to catch navigation commands
      @processor.start
    else
      # No need for the tracer unless we have a file context to step through
      start_without_pry_byebug(target, options)
    end
  end
  alias_method :start, :start_with_pry_byebug
end
