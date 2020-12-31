# frozen_string_literal: true

require "byebug/core"

module Byebug
  #
  # Extends the PryProcessor to make it work with Pry-Remote
  #
  class PryRemoteProcessor < PryProcessor
    class PryRemoteInterface
      attr_reader :output, :input

      def initialize(input, output)
        @input = input
        @output = output
      end
    end

    def self.start(input:, output:, **)
      super()

      Context.interface = PryRemoteInterface.new(input, output)
      Byebug.current_context.step_out(5, true)
    end

    def initialize(context, *)
      @interface = Context.interface

      super
    end

    def resume_pry
      new_binding = frame._binding

      run do
        if defined?(@pry) && @pry
          @pry.repl(new_binding)
        else
          @pry = Pry.start_without_pry_byebug(new_binding, input: @interface.input, output: @interface.output)
        end
      end
    end
  end
end
