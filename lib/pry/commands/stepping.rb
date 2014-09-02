require 'pry'

class Pry
  SteppingCommands = CommandSet.new do
    create_command 'step' do
      description 'Step execution into the next line or method.'

      banner <<-BANNER
        Usage: step [TIMES]
        Aliases: s

        Step execution forward. By default, moves a single step.

        Examples:
          step   #=> Move a single step forward.
          step 5 #=> Execute the next 5 steps.
      BANNER

      def process
        PryByebug.check_file_context(target)
        breakout_navigation :step, args.first
      end
    end
    alias_command 's', 'step'

    create_command 'next' do
      description 'Execute the next line within the current stack frame.'

      banner <<-BANNER
        Usage: next [LINES]
        Aliases: n

        Step over within the same frame. By default, moves forward a single
        line.

        Examples:
          next   #=> Move a single line forward.
          next 4 #=> Execute the next 4 lines.
      BANNER

      def process
        PryByebug.check_file_context(target)
        breakout_navigation :next, args.first
      end
    end
    alias_command 'n', 'next'

    create_command 'finish' do
      description 'Execute until current stack frame returns.'

      banner <<-BANNER
        Usage: finish
        Aliases: f
      BANNER

      def process
        PryByebug.check_file_context(target)
        breakout_navigation :finish
      end
    end
    alias_command 'f', 'finish'

    create_command 'continue' do
      description 'Continue program execution and end the Pry session.'

      banner <<-BANNER
        Usage: continue
        Aliases: c
      BANNER

      def process
        PryByebug.check_file_context(target)
        breakout_navigation :continue
      end
    end
    alias_command 'c', 'continue'

    helpers do
      def breakout_navigation(action, times = nil)
        _pry_.binding_stack.clear # Clear the binding stack.

        # Break out of the REPL loop and signal tracer
        throw :breakout_nav, action: action, times: times, pry: _pry_
      end
    end
  end

  Pry.commands.import(SteppingCommands)
end
