# frozen_string_literal: true

require "byebug/processors/pry_processor"

class << Pry::REPL
  alias start_without_pry_byebug start

  def start_with_pry_byebug(_ = {})
    Byebug::PryProcessor.start unless ENV["DISABLE_PRY"]
  end

  alias start start_with_pry_byebug
end
