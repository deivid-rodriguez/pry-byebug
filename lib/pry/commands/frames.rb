#
# Main Pry class.
#
# We're going to add to it custom frame commands for Pry-Byebug
#
class Pry
  FrameCommands = CommandSet.new do
    create_command 'up' do
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

    create_command 'down' do
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

    create_command 'frame' do
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

    helpers do
      def frame_navigation(action, options = {})
        _pry_.binding_stack.clear # Clear the binding stack.

        # Break out of the REPL loop and signal tracer
        throw :breakout_nav, action: action, options: options, pry: _pry_
      end
    end
  end

  Pry.commands.import(FrameCommands)
end
