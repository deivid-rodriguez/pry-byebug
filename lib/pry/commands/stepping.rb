#
# Main Pry class.
#
# We're going to add to it custom stepping commands for Pry-Byebug
#
class Pry
  SteppingCommands = CommandSet.new do
    create_command 'step' do
      description 'Step execution into the next line or method.'

      banner <<-BANNER
        Usage: step [TIMES]

        Step execution forward. By default, moves a single step.

        Examples:
          step   #=> Move a single step forward.
          step 5 #=> Execute the next 5 steps.
      BANNER

      def process
        PryByebug.check_file_context(target)

        breakout_navigation :step, times: args.first
      end
    end

    create_command 'next' do
      description 'Execute the next line within the current stack frame.'

      banner <<-BANNER
        Usage: next [LINES]

        Step over within the same frame. By default, moves forward a single
        line.

        Examples:
          next   #=> Move a single line forward.
          next 4 #=> Execute the next 4 lines.
      BANNER

      def process
        PryByebug.check_file_context(target)

        breakout_navigation :next, lines: args.first
      end
    end

    create_command 'finish' do
      description 'Execute until current stack frame returns.'

      banner <<-BANNER
        Usage: finish
      BANNER

      def process
        PryByebug.check_file_context(target)

        breakout_navigation :finish
      end
    end

    create_command 'continue' do
      description 'Continue program execution and end the Pry session.'

      banner <<-BANNER
        Usage: continue
      BANNER

      def process
        PryByebug.check_file_context(target)

        breakout_navigation :continue
      end
    end

    helpers do
      def breakout_navigation(action, options = {})
        _pry_.binding_stack.clear # Clear the binding stack.

        # Break out of the REPL loop and signal tracer
        throw :breakout_nav, action: action, options: options, pry: _pry_
      end
    end
  end

  Pry.commands.import(SteppingCommands)
end
