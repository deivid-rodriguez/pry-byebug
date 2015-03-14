require 'byebug'

module Byebug
  #
  # Extends raw byebug's processor.
  #
  class PryProcessor < Processor
    attr_accessor :pry
    attr_reader :state

    extend Forwardable
    def_delegators :@pry, :output
    def_delegators Pry::Helpers::Text, :bold

    def initialize(interface = LocalInterface.new)
      super(interface)

      Byebug.handler = self
      Byebug::Setting[:autolist] = false
    end

    def start
      Byebug.start
      Byebug.current_context.step_out(3, true)
    end

    #
    # Wrap a Pry REPL to catch navigational commands and act on them.
    #
    def run(&_block)
      @state ||= Byebug::RegularState.new(
        Byebug.current_context,
        [],
        Byebug.current_context.frame_file,
        interface,
        Byebug.current_context.frame_line
      )

      return_value = nil

      command = catch(:breakout_nav) do  # Throws from PryByebug::Commands
        return_value = yield
        {}    # Nothing thrown == no navigational command
      end

      # Pry instance to resume after stepping
      @pry = command[:pry]

      perform(command[:action], command[:options])

      return_value
    end

    #
    # Set up a number of navigational commands to be performed by Byebug.
    #
    def perform(action, options = {})
      return unless [
        :next, :step, :finish, :up, :down, :frame
      ].include?(action)

      send("perform_#{action}", options)
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

      output.puts bold("\n  Breakpoint #{breakpoint.id}. ") + n_hits(breakpoint)

      expr = breakpoint.expr
      return unless expr

      output.puts bold('Condition: ') + expr
    end

    private

    def n_hits(breakpoint)
      n_hits = breakpoint.hit_count

      n_hits == 1 ? 'First hit' : "Hit #{n_hits} times."
    end

    #
    # Resume an existing Pry REPL at the paused point.
    #
    def resume_pry(context)
      frame_position = state ? state.frame : 0

      new_binding = context.frame_binding(frame_position)

      run do
        if defined?(@pry) && @pry
          @pry.repl(new_binding)
        else
          @pry = Pry.start_without_pry_byebug(new_binding)
        end
      end
    end

    def perform_next(options)
      lines = (options[:lines] || 1).to_i
      state.context.step_over(lines, state.frame)
    end

    def perform_step(options)
      times = (options[:times] || 1).to_i
      state.context.step_into(times, state.frame)
    end

    def perform_finish(*)
      state.context.step_out(1)
    end

    def perform_up(options)
      times = (options[:times] || 1).to_i

      command = Byebug::UpCommand.new(state)
      command.match("up #{times}")
      command.execute

      resume_pry(state.context)
    end

    def perform_down(options)
      times = (options[:times] || 1).to_i

      command = Byebug::DownCommand.new(state)
      command.match("down #{times}")
      command.execute

      resume_pry(state.context)
    end

    def perform_frame(options)
      index = options[:index] ? options[:index].to_i : ''

      command = Byebug::FrameCommand.new(state)
      command.match("frame #{index}")
      command.execute

      resume_pry(state.context)
    end
  end
end
