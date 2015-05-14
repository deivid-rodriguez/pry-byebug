require 'pry-byebug/helpers/navigation'

module PryByebug
  #
  # Continue program execution until the next breakpoint
  #
  class ContinueCommand < Pry::ClassCommand
    include Helpers::Navigation

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
end

Pry::Commands.add_command(PryByebug::ContinueCommand)
