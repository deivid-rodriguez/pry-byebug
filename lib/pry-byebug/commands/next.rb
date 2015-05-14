require 'pry-byebug/helpers/navigation'

module PryByebug
  #
  # Run a number of lines and then stop again
  #
  class NextCommand < Pry::ClassCommand
    include Helpers::Navigation

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
end

Pry::Commands.add_command(PryByebug::NextCommand)
