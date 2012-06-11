require 'pry'
require 'pry-debugger/breakpoints'

module PryDebugger
  Commands = Pry::CommandSet.new do
    create_command 'step' do
      description 'Step execution into the next line or method.'

      banner <<-BANNER
        Usage: step [TIMES]

        Step execution forward. By default, moves a single step.

        Examples:

          step                           Move a single step forward.
          step 5                         Execute the next 5 steps.
      BANNER

      def process
        check_file_context
        breakout_navigation :step, args.first
      end
    end


    create_command 'next' do
      description 'Execute the next line within the same stack frame.'

      banner <<-BANNER
        Usage: next [LINES]

        Step over within the same frame. By default, moves forward a single
        line.

        Examples:

          next                           Move a single line forward.
          next 4                         Execute the next 4 lines.
      BANNER

      def process
        check_file_context
        breakout_navigation :next, args.first
      end
    end


    create_command 'continue' do
      description 'Continue program execution and end the Pry session.'

      def process
        check_file_context
        run 'exit-all'
      end
    end


    create_command 'break' do
      description 'Set or edit a breakpoint.'

      banner <<-BANNER
        Usage:   break [METHOD | FILE:LINE | LINE]
                 break [--delete | --enable | --disable] N
                 break [--delete-all | --disable-all]
        Aliases: breakpoint

        Set a breakpoint. Accepts a line number in the current file, a file and
        line number, or a method.

        Pass appropriate flags to manipulate existing breakpoints.

        Examples:

          break SomeClass#run            Break at the start of `SomeClass#run`
          break app/models/user.rb:15    Break at line 15 in user.rb
          break 14                       Break at line 14 in the current file.
          break --delete 5               Delete breakpoint #5.
          break --disable-all            Disable all breakpoints.
      BANNER

      def options(opt)
        opt.on :D, :delete,  'Delete a breakpoint.', :argument => true, :as => Integer
        opt.on :d, :disable, 'Disable a breakpoint.', :argument => true, :as => Integer
        opt.on :e, :enable,  'Enable a disabled breakpoint.', :argument => true, :as => Integer
        opt.on :'disable-all', 'Disable all breakpoints.'
        opt.on :'delete-all',  'Delete all breakpoints.'
        method_options(opt)
      end

      def process
        Pry.processor.pry = _pry_

        { :delete        => :delete,
          :disable       => :disable,
          :enable        => :enable,
          :'disable-all' => :disable_all,
          :'delete-all'  => :clear
        }.each do |action, method|
          if opts.present?(action)
            Breakpoints.__send__ method, *(method == action ? [opts[action]] : [])
            return run 'breaks'
          end
        end

        new_breakpoint
      end

      def new_breakpoint
        file, line =
          case args.join
          when /(\d+)/       # Line number only
            line = $1
            unless PryDebugger.check_file_context(target)
              raise ArgumentError, 'Line number declaration valid only in a file context.'
            end
            [target.eval('__FILE__'), line]
          when /(.+):(\d+)/  # File and line number
            [$1, $2]
          else               # Method or class name
            method_object.source_location
          end

        print_full_breakpoint Breakpoints.add(file, line.to_i)
      end
    end
    alias_command 'breakpoint', 'break'


    create_command 'breakpoints' do
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
        if Breakpoints.count > 0
          if opts.verbose?   # Long-form with source output
            Breakpoints.each { |b| print_full_breakpoint(b) }
          else               # Simple table output
            max_width = [Math.log10(Breakpoints.count).ceil, 1].max
            header = "#{' ' * (max_width - 1)}#  Enabled  At "

            output.puts
            output.puts text.bold(header)
            output.puts text.bold('-' * header.size)
            Breakpoints.each do |breakpoint|
              output.printf "%#{max_width}d  ", breakpoint.id
              output.print  breakpoint.enabled? ? 'Yes      ' : 'No       '
              output.puts   "#{breakpoint.source}:#{breakpoint.pos}"
            end
            output.puts
          end
        else
          output.puts text.bold('No breakpoints defined.')
        end
      end
    end
    alias_command 'breaks', 'breakpoints'


    helpers do
      def breakout_navigation(action, times)
        _pry_.binding_stack.clear     # Clear the binding stack.
        throw :breakout_nav, {        # Break out of the REPL loop and
          :action => action,          #   signal the tracer.
          :times =>  times,
          :pry => _pry_
        }
      end

      # Ensures that a command is executed in a local file context.
      def check_file_context
        unless PryDebugger.check_file_context(target)
          raise Pry::CommandError, 'Cannot find local context. Did you use `binding.pry`?'
        end
      end

      # Print out full information about a breakpoint including surrounding code
      # at that point.
      def print_full_breakpoint(breakpoint)
        line = breakpoint.pos
        output.print text.bold("Breakpoint #{breakpoint.id}: ")
        output.print "#{breakpoint.source} @ line #{line} "
        output.print breakpoint.enabled? ? '(Enabled)' : '(Disabled)'
        output.puts  ' :'
        output.puts
        output.puts  Pry::Code.from_file(breakpoint.source).
                       around(line, 3).
                       with_line_numbers.
                       with_marker(line).to_s
        output.puts
      end
    end
  end
end

Pry.commands.import PryDebugger::Commands
