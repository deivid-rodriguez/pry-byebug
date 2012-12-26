module PryDebugger

  # Wrapper for Debugger.breakpoints that respects our Processor and has better
  # failure behavior. Acts as an Enumerable.
  #
  module Breakpoints
    extend Enumerable
    extend self


    # Add a new breakpoint.
    def add(file, line, expression = nil)
      real_file = (file != Pry.eval_path)
      raise ArgumentError, 'Invalid file!' if real_file && !File.exist?(file)
      validate_expression expression

      Pry.processor.debugging = true

      path = (real_file ? File.expand_path(file) : file)
      Debugger.add_breakpoint(path, line, expression)
    end

    # Change the conditional expression for a breakpoint.
    def change(id, expression = nil)
      validate_expression expression

      breakpoint = find_by_id(id)
      breakpoint.expr = expression
      breakpoint
    end

    # Delete an existing breakpoint with the given ID.
    def delete(id)
      unless Debugger.started? && Debugger.remove_breakpoint(id)
        raise ArgumentError, "No breakpoint ##{id}"
      end
      Pry.processor.debugging = false if to_a.empty?
    end

    # Delete all breakpoints.
    def clear
      Debugger.breakpoints.clear if Debugger.started?
      Pry.processor.debugging = false
    end

    # Enable a disabled breakpoint with the given ID.
    def enable(id)
      change_status id, true
    end

    # Disable a breakpoint with the given ID.
    def disable(id)
      change_status id, false
    end

    # Disable all breakpoints.
    def disable_all
      each do |breakpoint|
        breakpoint.enabled = false
      end
    end

    def to_a
      Debugger.started? ? Debugger.breakpoints : []
    end

    def size
      to_a.size
    end

    def each(&block)
      to_a.each(&block)
    end

    def find_by_id(id)
      breakpoint = find { |b| b.id == id }
      raise ArgumentError, "No breakpoint ##{id}!" unless breakpoint
      breakpoint
    end


   private

    def change_status(id, enabled = true)
      breakpoint = find_by_id(id)
      breakpoint.enabled = enabled
      breakpoint
    end

    def validate_expression(expression)
      if expression &&   # `nil` implies no expression given, so pass
          (expression.empty? || !Pry::Code.complete_expression?(expression))
        raise "Invalid breakpoint conditional: #{expression}"
      end
    end
  end
end
