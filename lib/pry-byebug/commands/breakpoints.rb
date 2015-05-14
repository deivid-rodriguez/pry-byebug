require 'pry/byebug/breakpoints'
require 'pry-byebug/helpers/breakpoints'

module PryByebug
  #
  # List breakpoints
  #
  class BreakpointsCommand < Pry::ClassCommand
    include Helpers::Breakpoints

    match 'breakpoints'
    group 'Byebug'
    description 'List defined breakpoints.'

    banner <<-BANNER
      Usage:   breakpoints [OPTIONS]
      Aliases: breaks

      List registered breakpoints and their current status.
    BANNER

    def options(opt)
      opt.on :v, :verbose, 'Print source around each breakpoint.'
    end

    def process
      PryByebug.check_file_context(target)

      return bold_puts('No breakpoints defined.') if breakpoints.count == 0

      if opts.verbose?
        breakpoints.each { |b| print_full_breakpoint(b) }
      else
        print_breakpoints_header
        breakpoints.each { |b| print_short_breakpoint(b) }
      end
    end
  end
end

Pry::Commands.add_command(PryByebug::BreakpointsCommand)
Pry::Commands.alias_command 'breaks', 'breakpoints'
