# frozen_string_literal: true

#
# Toy class for testing frame commands
#
class FramesExample
  def method_a
    method_b
  end

  def method_b
    binding.pry
  end
end

FramesExample.new.method_a
