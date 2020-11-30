# frozen_string_literal: true

require "pry-byebug" if defined? Pry # Make Pry's plugin autoload properly mark this gem
require "pry-byebug/base"
require "pry-byebug/pry_ext"
require "pry-byebug/commands"
require "pry-byebug/control_d_handler"
