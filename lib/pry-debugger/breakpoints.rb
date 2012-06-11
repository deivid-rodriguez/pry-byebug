module PryDebugger

  # Wrapper for Debugger.breakpoints that respects our Processor and has better
  # failure behavior. Acts as an Enumerable.
  #
  module Breakpoints
    extend Enumerable
    extend self


    # Add a new breakpoint.
    def add(file, line, expression = nil)
      raise ArgumentError, 'Invalid file!' unless File.exist?(file)
      Pry.processor.debugging = true
      Debugger.add_breakpoint(File.expand_path(file), line)
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


   private

    def change_status(id, enabled = true)
      breakpoint = find { |b| b.id == id }
      if breakpoint
        breakpoint.enabled = enabled
        breakpoint
      else
        raise ArgumentError, "No breakpoint ##{id}!"
      end
    end
  end
end
