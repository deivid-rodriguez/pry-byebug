require 'pry'
require 'byebug'

module PryByebug
  class Processor < Byebug::Processor
    attr_accessor :pry

    def initialize(interface = Byebug::LocalInterface.new)
      super(interface)
      
      Byebug.handler = self
      @always_enabled = true
      @delayed = Hash.new(0)
    end

    # Wrap a Pry REPL to catch navigational commands and act on them.
    def run(initial = true, &block)
      return_value = nil

      command = catch(:breakout_nav) do  # Throws from PryByebug::Commands
        return_value = yield
        {}    # Nothing thrown == no navigational command
      end

      times = (command[:times] || 1).to_i   # Command argument
      times = 1 if times <= 0

      if [:step, :next, :finish].include? command[:action]
        @pry = command[:pry]   # Pry instance to resume after stepping
        Byebug.start unless Byebug.started?

        if initial
          # Movement when on the initial binding.pry line will have a frame
          # inside Byebug. If we step normally, it'll stop inside this
          # Processor. So jump out and stop at the above frame, then step/next
          # from our callback.
          @delayed[command[:action]] = times
          Byebug.current_context.step_out(2)
        elsif :next == command[:action]
          Byebug.current_context.step_over(times, 0)

        elsif :step == command[:action]
          Byebug.current_context.step_into(times)

        elsif :finish == command[:action]
          Byebug.current_context.step_out(0)
        end
      else
        stop
      end

      return_value
    end

    # Adjust debugging. When set to false, the Processor will manage enabling
    # and disabling the debugger itself. When set to true, byebug is always
    # enabled.
    def debugging=(enabled)
      if enabled
        @always_enabled = true
        Byebug.start unless Byebug.started?
      else
        @always_enabled = false
        # Byebug will get stopped if necessary in `stop` once the repl ends.
      end
    end

    # --- Callbacks from byebug C extension ---
    def at_line(context, file, line)
       # If any delayed nexts/steps, do 'em.
      if @delayed[:next] > 1
        context.step_over(@delayed[:next] - 1, 0)

      elsif @delayed[:step] > 1
        context.step_into(@delayed[:step] - 1)

      elsif @delayed[:finish] > 1
        context.step_out(@delayed[:finish] - 1)

      # Otherwise, resume the pry session at the stopped line.
      else
        resume_pry context
      end

      @delayed = Hash.new(0)
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
        @pry.output.puts expr
      end
    end

    def at_catchpoint(context, exception)
      # TODO
    end

    private

      #
      # Resume an existing Pry REPL at the paused point.
      #
      def resume_pry(context)
        new_binding = context.frame_binding(0)
        Byebug.stop unless @always_enabled

        run(false) do
          @pry.repl new_binding
        end
      end

      # Cleanup when debugging is stopped and execution continues.
      def stop
        Byebug.stop if !@always_enabled && Byebug.started?
        if PryByebug.current_remote_server   # Cleanup DRb remote if running
          PryByebug.current_remote_server.teardown
        end
      end
  end
end
