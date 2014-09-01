module PryByebug
  #
  # Checks that a binding is in a local file context. Extracted from
  #
  def check_file_context(target)
    file = target.eval('__FILE__')
    file == Pry.eval_path || !Pry::Helpers::BaseHelpers.not_a_real_file?(file)
  end
  module_function :check_file_context

  # Reference to currently running pry-remote server. Used by the processor.
  attr_accessor :current_remote_server
end
