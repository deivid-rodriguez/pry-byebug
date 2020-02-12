# frozen_string_literal: true

module PryByebug
  module Helpers
    #
    # Helpers to aid breaking out of the REPL loop
    #
    module Navigation
      #
      # Breaks out of the REPL loop and signals tracer
      #
      def breakout_navigation(action, options = {})
        preferred_pry_instance = if respond_to?(:pry_instance)
                                   pry_instance
                                 else
                                   _pry_
                                 end

        preferred_pry_instance.binding_stack.clear

        throw :breakout_nav, action: action, options: options, pry: preferred_pry_instance
      end
    end
  end
end
