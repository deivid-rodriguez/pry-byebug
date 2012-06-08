require 'pry'
require 'debugger'

module PryDebugger
  class Processor
    def initialize
      Debugger.handler = self
      @pry, @always_enabled = nil, nil
      @delayed = Hash.new(0)
    end

    def run(&block)
      return_value = nil
      command = catch(:breakout_nav) do  # Throws from PryDebugger::Commands
        return_value = yield
        {}    # Nothing thrown == no navigational command
      end

      times = (command[:times] || 1).to_i   # Command argument
      times = 1 if times <= 0

      if [:step, :next].include? command[:action]
        @pry = command[:pry]   # Pry instance to resume after stepping
        Debugger.start

        if Debugger.current_context.frame_self.is_a? Debugger::Context
          # Movement when on the binding.pry line will have a frame inside
          # Debugger. If we step normally, it'll stop inside this Processor. So
          # jump out and stop at the above frame, then step/next from our
          # callback.
          Debugger.current_context.stop_frame = 1
          @delayed[command[:action]] = times

        elsif :next == command[:action]
          Debugger.current_context.step_over(times, 0)

        else  # step
          Debugger.current_context.step(times)
        end

      else   # Continuing execution... cleanup DRb remote if running
        Debugger.stop if !@always_enabled && Debugger.started?
        if PryDebugger.current_remote_server
          PryDebugger.current_remote_server.teardown
        end
      end

      return_value
    end

    def add_breakpoint(pry, file, line, expression = nil)
      @pry = pry
      @always_enabled = true
      Debugger.start
      Debugger.add_breakpoint(File.expand_path(file), line)
    end

    # --- Callbacks from debugger C extension ---

    def at_line(context, file, line)
      return if file && TRACE_IGNORE_FILES.include?(File.expand_path(file))

      if @delayed[:next] > 1     # If any delayed nexts/steps, do 'em.
        Debugger.current_context.step_over(@delayed[:next] - 1, 0)
        @delayed = Hash.new(0)

      elsif @delayed[:step] > 1
        Debugger.current_context.step(@delayed[:step] - 1)
        @delayed = Hash.new(0)

      else  # Otherwise, resume the pry session at the stopped line.
        resume_pry context
      end
    end

    def at_breakpoint(context, breakpoint)
      resume_pry context
    end

    def at_catchpoint(context, exception)
      # TODO
    end


   private

    def resume_pry(context)
      new_binding = context.frame_binding(0)
      Debugger.stop unless @always_enabled

      @pry.binding_stack.clear
      run do
        @pry.repl new_binding
      end
    end
  end
end
