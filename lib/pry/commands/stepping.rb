#
# Main Pry class.
#
# We're going to add to it custom stepping commands for Pry-Byebug
#

module ByebugCommandHelpers
  def breakout_navigation(action, options = {})
    _pry_.binding_stack.clear # Clear the binding stack.

    # Break out of the REPL loop and signal tracer
    throw :breakout_nav, action: action, options: options, pry: _pry_
  end
end

class ByebugCommand < Pry::ClassCommand
  include ByebugCommandHelpers
end

class Pry
  class Command::Step < ByebugCommand
    match 'step'
    group 'Byebug'
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

      breakout_navigation :step, args.first
    end
  end

  class Command::Next < ByebugCommand
    match 'next'
    group 'Byebug'
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

  class Command::Finish < ByebugCommand
    match 'finish'
    group 'Byebug'
    description 'Execute until current stack frame returns.'

    banner <<-BANNER
        Usage: finish
      BANNER

    def process
      PryByebug.check_file_context(target)

      breakout_navigation :finish
    end
  end

  class Command::Continue < ByebugCommand
    match 'continue'
    group 'Byebug'
    description 'Continue program execution and end the Pry session.'

    banner <<-BANNER
        Usage: continue
      BANNER

    def process
      PryByebug.check_file_context(target)

      breakout_navigation :continue
    end

  end

  Pry::Commands.add_command(Pry::Command::Step)
  Pry::Commands.add_command(Pry::Command::Next)
  Pry::Commands.add_command(Pry::Command::Finish)
  Pry::Commands.add_command(Pry::Command::Continue)
end
