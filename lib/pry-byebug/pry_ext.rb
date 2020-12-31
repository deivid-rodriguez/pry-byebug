# frozen_string_literal: true

require "byebug/processors/pry_processor"
require "byebug/processors/pry_remote_processor"

class << Pry
  alias start_without_pry_byebug start

  def start_with_pry_byebug(target = TOPLEVEL_BINDING, options = {})
    if target.is_a?(Binding) && PryByebug.file_context?(target) && !ENV["DISABLE_PRY"]
      PryByebug.current_remote_server ? Byebug::PryRemoteProcessor.start(options) : Byebug::PryProcessor.start
    else
      # No need for the tracer unless we have a file context to step through
      start_without_pry_byebug(target, options)
    end
  end

  alias start start_with_pry_byebug
end
