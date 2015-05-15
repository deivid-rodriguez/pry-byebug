require 'pry/byebug/breakpoints'
require 'pry-byebug/helpers/breakpoints'
require 'pry-byebug/helpers/multiline'

module PryByebug
  #
  # Add, show and remove breakpoints
  #
  class BreakCommand < Pry::ClassCommand
    include Helpers::Breakpoints
    include Helpers::Multiline

    match 'break'
    group 'Byebug'
    description 'Set or edit a breakpoint.'

    banner <<-BANNER
      Usage:   break <METHOD | FILE:LINE | LINE> [if CONDITION]
               break --condition N [CONDITION]
               break [--show | --delete | --enable | --disable] N
               break [--delete-all | --disable-all]
               break
      Aliases: breakpoint

      Set a breakpoint. Accepts a line number in the current file, a file and
      line number, or a method, and an optional condition.

      Pass appropriate flags to manipulate existing breakpoints.

      Examples:

        break SomeClass#run         Break at the start of `SomeClass#run`.
        break Foo#bar if baz?       Break at `Foo#bar` only if `baz?`.
        break app/models/user.rb:15 Break at line 15 in user.rb.
        break 14                    Break at line 14 in the current file.

        break --condition 4 x > 2   Add/change condition on breakpoint #4.
        break --condition 3         Remove the condition on breakpoint #3.

        break --delete 5            Delete breakpoint #5.
        break --disable-all         Disable all breakpoints.

        break --show 2              Show details about breakpoint #2.
        break                       List all breakpoints.
    BANNER

    def options(opt)
      defaults = { argument: true, as: Integer }

      opt.on :c, :condition, 'Change condition of a breakpoint.', defaults
      opt.on :s, :show, 'Show breakpoint details and source.', defaults
      opt.on :D, :delete, 'Delete a breakpoint.', defaults
      opt.on :d, :disable, 'Disable a breakpoint.', defaults
      opt.on :e, :enable, 'Enable a disabled breakpoint.', defaults
      opt.on :'disable-all', 'Disable all breakpoints.'
      opt.on :'delete-all', 'Delete all breakpoints.'
    end

    def process
      return if check_multiline_context

      PryByebug.check_file_context(target)

      all = %w(condition show delete disable enable disable-all delete-all)
      all.each do |option|
        next unless opts.present?(option)

        return send("process_#{option.gsub('-', '_')}")
      end

      return new_breakpoint unless args.empty?

      print_all
    end

    private

    %w(delete disable enable).each do |command|
      define_method(:"process_#{command}") do
        breakpoints.send(command, opts[command])
        print_all
      end
    end

    %w(disable-all delete-all).each do |command|
      method_name = command.gsub('-', '_')
      define_method(:"process_#{method_name}") do
        breakpoints.send(method_name)
        print_all
      end
    end

    def process_show
      print_full_breakpoint(breakpoints.find_by_id(opts[:show]))
    end

    def process_condition
      expr = args.empty? ? nil : args.join(' ')
      breakpoints.change(opts[:condition], expr)
    end

    def new_breakpoint
      place = args.shift
      condition = args.join(' ') if 'if' == args.shift

      bp = add_breakpoint(place, condition)

      print_full_breakpoint(bp)
    end

    def print_all
      print_breakpoints_header
      breakpoints.each { |b| print_short_breakpoint(b) }
    end

    def add_breakpoint(place, condition)
      case place
      when /^(\d+)$/
        errmsg = 'Line number declaration valid only in a file context.'
        PryByebug.check_file_context(target, errmsg)

        lineno = Regexp.last_match[1].to_i
        breakpoints.add_file(current_file, lineno, condition)
      when /^(.+):(\d+)$/
        file = Regexp.last_match[1]
        lineno = Regexp.last_match[2].to_i
        breakpoints.add_file(file, lineno, condition)
      when /^(.*)[.#].+$/  # Method or class name
        if Regexp.last_match[1].strip.empty?
          errmsg = 'Method name declaration valid only in a file context.'
          PryByebug.check_file_context(target, errmsg)
          place = target.eval('self.class.to_s') + place
        end
        breakpoints.add_method(place, condition)
      else
        fail(ArgumentError, 'Cannot identify arguments as breakpoint')
      end
    end
  end
end

Pry::Commands.add_command(PryByebug::BreakCommand)
Pry::Commands.alias_command 'breakpoint', 'break'
