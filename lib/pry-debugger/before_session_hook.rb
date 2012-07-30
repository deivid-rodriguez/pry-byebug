module PryDebugger
  class BeforeSessionHook

    def caller_bindings(target)

      bindings = binding.callers

      start_frames = bindings.each_with_index.select do |b, i|
        (b.frame_type == :method &&
         b.eval("self.class") == Debugger::Context &&
         b.eval("__method__") == :at_line)
      end

      start_frame_index = start_frames.first.last
      bindings = bindings.drop(start_frame_index + 1)

      bindings
    end

    def call(output, target, _pry_)
      return if binding.callers.map(&:frame_description).include?("start")
		  bindings = caller_bindings(target)
      PryStackExplorer.create_and_push_frame_manager bindings, _pry_, :initial_frame => 0
    end
  end
end