require 'pry'
require 'debugger'

module PryDebugger
  class Processor
    attr_accessor :pry

    def initialize
      Debugger.handler = self
      @always_enabled = false
      @delayed = Hash.new(0)
    end

    # Wrap a Pry REPL to catch navigational commands and act on them.
    def run(initial = true, &block)
      return_value = nil
      command = catch(:breakout_nav) do  # Throws from PryDebugger::Commands
        return_value = yield
        {}    # Nothing thrown == no navigational command
      end

      times = (command[:times] || 1).to_i   # Command argument
      times = 1 if times <= 0

      if [:step, :next, :finish].include? command[:action]
        @pry = command[:pry]   # Pry instance to resume after stepping
        Debugger.start unless Debugger.started?

        if initial
          # Movement when on the initial binding.pry line will have a frame
          # inside Debugger. If we step normally, it'll stop inside this
          # Processor. So jump out and stop at the above frame, then step/next
          # from our callback.
          Debugger.current_context.stop_frame = 1
          @delayed[command[:action]] = times

        elsif :next == command[:action]
          step_over times

        elsif :step == command[:action]
          step times

        elsif :finish == command[:action]
          finish
        end
      else
        stop
      end

      return_value
    end

    # Adjust debugging. When set to false, the Processor will manage enabling
    # and disabling the debugger itself. When set to true, the debugger is
    # always enabled.
    def debugging=(enabled)
      if enabled
        @always_enabled = true
        Debugger.start unless Debugger.started?
      else
        @always_enabled = false
        # Debugger will get stopped if necessary in `stop` once the repl ends.
      end
    end


    # --- Callbacks from debugger C extension ---

    def at_line(context, file, line)
      return if file && TRACE_IGNORE_FILES.include?(File.expand_path(file))

      # If stopped for a breakpoint or catchpoint, can't play any delayed steps
      # as they'll move away from the interruption point. (Unsure if scenario is
      # possible, but just keeping assertions in check.)
      @delayed = Hash.new(0) unless :step == context.stop_reason

      if @delayed[:next] > 1     # If any delayed nexts/steps, do 'em.
        step_over @delayed[:next] - 1
        @delayed = Hash.new(0)

      elsif @delayed[:step] > 1
        step @delayed[:step] - 1
        @delayed = Hash.new(0)

      elsif @delayed[:finish] > 0
        finish
        @delayed = Hash.new(0)

      else  # Otherwise, resume the pry session at the stopped line.
        resume_pry context
      end
    end

    # Called when a breakpoint is triggered. Note: `at_line`` is called
    # immediately after with the context's `stop_reason == :breakpoint`.
    def at_breakpoint(context, breakpoint)
      @pry.output.print Pry::Helpers::Text.bold("\nBreakpoint #{breakpoint.id}. ")
      @pry.output.puts  (breakpoint.hit_count == 1 ?
                           'First hit.' :
                           "Hit #{breakpoint.hit_count} times." )
      if (expr = breakpoint.expr)
        @pry.output.print Pry::Helpers::Text.bold("Condition: ")
        @pry.output.puts  expr
      end
    end

    def at_catchpoint(context, exception)
      # TODO
    end


   private

    # Resume an existing Pry REPL at the paused point. Binding extracted from
    # the Debugger::Context.
    def resume_pry(context)
      new_binding = context.frame_binding(0)
      Debugger.stop unless @always_enabled

      @pry.binding_stack.clear
      run(false) do
        @pry.repl new_binding
      end
    end

    # Move execution forward.
    def step(times)
      Debugger.current_context.step(times)
    end

    # Move execution forward a number of lines in the same frame.
    def step_over(lines)
      Debugger.current_context.step_over(lines, 0)
    end

    # Execute until current frame returns.
    def finish
      Debugger.current_context.stop_frame = 0
    end

    # Cleanup when debugging is stopped and execution continues.
    def stop
      Debugger.stop if !@always_enabled && Debugger.started?
      if PryDebugger.current_remote_server   # Cleanup DRb remote if running
        PryDebugger.current_remote_server.teardown
      end
    end
  end
end
