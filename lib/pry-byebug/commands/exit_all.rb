# frozen_string_literal: true

require "pry/commands/exit_all"

module PryByebug
  #
  # Exit pry REPL with Byebug.stop
  #
  class ExitAllCommand < Pry::Command::ExitAll
    def process
      super
    ensure
      PryByebug.current_remote_server&.teardown
      Byebug.stop if Byebug.stoppable?
    end
  end
end

Pry::Commands.add_command(PryByebug::ExitAllCommand)
