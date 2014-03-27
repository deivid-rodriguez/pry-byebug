module PryByebug

  # Wrapper for Byebug.breakpoints that respects our Processor and has better
  # failure behavior. Acts as an Enumerable.
  #
  module Breakpoints
    extend Enumerable
    extend self

    class FileBreakpoint < SimpleDelegator
      def source_code
        Pry::Code.from_file(source).around(pos, 3).with_marker(pos)
      end

      def to_s
        "#{source} @ #{pos}"
      end
    end

    class MethodBreakpoint < SimpleDelegator
      def initialize(byebug_bp, method)
        __setobj__ byebug_bp
        @method = method
      end

      def source_code
        Pry::Code.from_method(Pry::Method.from_str(@method))
      end

      def to_s
        @method
      end
    end

    def breakpoints
      @breakpoints ||= []
    end

    # Add method breakpoint.
    def add_method(method, expression = nil)
      validate_expression expression
      Pry.processor.debugging = true
      owner, name = method.split(/[\.#]/)
      byebug_bp = Byebug.add_breakpoint(owner, name.to_sym, expression)
      bp = MethodBreakpoint.new byebug_bp, method
      breakpoints << bp
      bp
    end

    # Add file breakpoint.
    def add_file(file, line, expression = nil)
      real_file = (file != Pry.eval_path)
      raise ArgumentError, 'Invalid file!' if real_file && !File.exist?(file)
      validate_expression expression

      Pry.processor.debugging = true

      path = (real_file ? File.expand_path(file) : file)
      bp = FileBreakpoint.new Byebug.add_breakpoint(path, line, expression)
      breakpoints << bp
      bp
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
      deleted = Byebug.started? && 
        Byebug.remove_breakpoint(id) &&
        breakpoints.delete(find_by_id(id))
      raise ArgumentError, "No breakpoint ##{id}" if not deleted
      Pry.processor.debugging = false if to_a.empty?
    end

    # Delete all breakpoints.
    def clear
      @breakpoints = []
      Byebug.breakpoints.clear if Byebug.started?
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
      breakpoints
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
