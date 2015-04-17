#
# Main Pry class.
#
# We're going to add to it custom frame commands for Pry-Byebug
#

module ByebugCommandHelpers
  def frame_navigation(action, options = {})
    _pry_.binding_stack.clear # Clear the binding stack.

    # Break out of the REPL loop and signal tracer
    throw :breakout_nav, action: action, options: options, pry: _pry_
  end
end

class ByebugCommand < Pry::ClassCommand
  include ByebugCommandHelpers
end

class Pry
  class Command::Up < ByebugCommand
    match 'up'
    group 'Byebug'

    description 'Move current frame up.'

    banner <<-BANNER
        Usage: up [TIMES]

        Move current frame up. By default, moves by 1 frame.

        Examples:
          up   #=> Move up 1 frame.
          up 5 #=> Move up 5 frames.
      BANNER

    def process
      PryByebug.check_file_context(target)

      frame_navigation :up, times: args.first
    end
  end

  class Command::Down < ByebugCommand
    match 'down'
    group 'Byebug'

    description 'Move current frame down.'

    banner <<-BANNER
        Usage: down [TIMES]

        Move current frame down. By default, moves by 1 frame.

        Examples:
          down   #=> Move down 1 frame.
          down 5 #=> Move down 5 frames.
      BANNER

    def process
      PryByebug.check_file_context(target)

      frame_navigation :down, times: args.first
    end
  end

  class Command::Frame < ByebugCommand
    match 'frame'
    group 'Byebug'

    description 'Move to specified frame #.'

    banner <<-BANNER
        Usage: frame [TIMES]

        Move to specified frame #.

        Examples:
          frame   #=> Show current frame #.
          frame 5 #=> Move to frame 5.
      BANNER

    def process
      PryByebug.check_file_context(target)

      frame_navigation :frame, index: args.first
    end
  end

  Pry::Commands.add_command(Pry::Command::Up)
  Pry::Commands.add_command(Pry::Command::Down)
  Pry::Commands.add_command(Pry::Command::Frame)
end
