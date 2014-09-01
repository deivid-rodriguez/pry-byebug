require 'pry'
require 'byebug'

module PryByebug
  #
  # Extends raw byebug's processor.
  #
  class Processor < Byebug::Processor
    attr_accessor :pry

    def initialize(interface = Byebug::LocalInterface.new)
      super(interface)

      Byebug.handler = self
    end

    # Wrap a Pry REPL to catch navigational commands and act on them.
    def run(initial = false, &_block)
      return_value = nil

      if initial
        Byebug.start
        Byebug.current_context.step_out(3)
      else
        command = catch(:breakout_nav) do  # Throws from PryByebug::Commands
          return_value = yield
          {}    # Nothing thrown == no navigational command
        end

        times = (command[:times] || 1).to_i   # Command argument
        times = 1 if times <= 0

        if [:step, :next, :finish].include? command[:action]
          @pry = command[:pry]   # Pry instance to resume after stepping

          if :next == command[:action]
            Byebug.current_context.step_over(times, 0)

          elsif :step == command[:action]
            Byebug.current_context.step_into(times)

          elsif :finish == command[:action]
            Byebug.current_context.step_out(times)
          end
        end
      end

      return_value
    end

    # --- Callbacks from byebug C extension ---

    #
    # Called when the wants to stop at a regular line
    #
    def at_line(context, _file, _line)
      resume_pry(context)
    end

    #
    # Called when the wants to stop right before a method return
    #
    def at_return(context, _file, _line)
      resume_pry(context)
    end

    #
    # Called when a breakpoint is hit. Note that `at_line`` is called
    # inmediately after with the context's `stop_reason == :breakpoint`, so we
    # must not resume the pry instance here
    #
    def at_breakpoint(_context, breakpoint)
      @pry ||= Pry.new

      brkpt_num = "\nBreakpoint #{breakpoint.id}. "
      @pry.output.print Pry::Helpers::Text.bold(brkpt_num)

      n_hits = breakpoint.hit_count
      @pry.output.puts(n_hits == 1 ? 'First hit' : "Hit #{n_hits} times.")

      expr = breakpoint.expr
      return unless expr

      @pry.output.print Pry::Helpers::Text.bold('Condition: ')
      @pry.output.puts expr
    end

    private

    #
    # Resume an existing Pry REPL at the paused point.
    #
    def resume_pry(context)
      new_binding = context.frame_binding(0)

      run(false) do
        if @pry
          @pry.repl(new_binding)
        else
          @pry = Pry.start_without_pry_byebug(new_binding)
        end
      end
    end
  end
end
