module PryDebugger

  # Wrapper for Debugger.breakpoints that respects our Processor and has better
  # failure behavior. Acts as an Enumerable.
  #
  module Breakpoints
    extend Enumerable
    extend self


    # Add a new breakpoint.
    def add(file, line, expression = nil)
      if !File.exist?(file) && file != Pry.eval_path
        raise ArgumentError, 'Invalid file!' unless File.exist?(file)
      end
      validate_expression expression

      Pry.processor.debugging = true

      path = file == Pry.eval_path ? file : File.expand_path(file)
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
      # `complete_expression?` throws a SyntaxError on invalid input.
      expression && Pry::Code.complete_expression?(expression)
    end
  end
end
