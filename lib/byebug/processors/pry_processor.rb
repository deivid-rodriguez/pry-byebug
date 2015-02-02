require 'pry'
require 'byebug'

module Byebug
  #
  # Extends raw byebug's processor.
  #
  class PryProcessor < Processor
    attr_accessor :pry

    def initialize(interface = LocalInterface.new)
      super(interface)

      Byebug.handler = self
    end

    def start
      Byebug.start
      Byebug.current_context.step_out(3, true)
    end

    #
    # Wrap a Pry REPL to catch navigational commands and act on them.
    #
    def run(&_block)
      return_value = nil

      command = catch(:breakout_nav) do  # Throws from PryByebug::Commands
        return_value = yield
        {}    # Nothing thrown == no navigational command
      end

      # Pry instance to resume after stepping
      @pry = command[:pry]

      perform(command[:action], (command[:times] || '1').to_i)

      return_value
    end

    #
    # Set up a number of navigational commands to be performed by Byebug.
    #
    def perform(action, times)
      case action
      when :next
        Byebug.current_context.step_over(times, 0)
      when :step
        Byebug.current_context.step_into(times)
      when :finish
        Byebug.current_context.step_out(times)
      end
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

      brkpt_num = "\n  Breakpoint #{breakpoint.id}. "
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

      run do
        if @pry
          @pry.repl(new_binding)
        else
          @pry = Pry.start_without_pry_byebug(new_binding)
        end
      end
    end
  end
end
