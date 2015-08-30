require 'byebug/processors/pry_processor'

#
# Adds a `pry_byebug` method to the Kernel module.
#
# Dropping a `pry_byebug` call anywhere in your code, you get a debug prompt.
#
module Kernel
  def pry_byebug
    Byebug::PryProcessor.start
  end
end
