require 'pry'
require 'debugger'

module PryDebugger
  class Processor
    def initialize(pry_start_options = {}, &block)
      Debugger.handler = self
      @pry_start_options = pry_start_options
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
        Debugger.start
        if Debugger.current_context.frame_self.is_a? Debugger::Context
          # The first binding.pry call will have a frame inside Debugger. If we
          # step normally, it'll stop inside this Processor instead. So jump it
          # out to the above frame.
          #
          # TODO: times isn't respected
          Debugger.current_context.stop_frame = 1
        else
          if :next == command[:action]
            Debugger.current_context.step_over(times, 0)
          else  # step
            Debugger.current_context.step(times)
          end
        end
      end

      return_value
    end


    # --- Callbacks from debugger C extension ---

    def at_line(context, file, line)
      start_pry context
    end

    def at_breakpoint(context, breakpoint)
      # TODO
    end

    def at_catchpoint(context, exception)
      # TODO
    end


   private

    def start_pry(context)
      Pry.start(context.frame_binding(0), @pry_start_options)
    end
  end
end
