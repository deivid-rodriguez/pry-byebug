#
# Toy class for testing frame commands
#
class Frames
  def method_a
    method_b
  end

  def method_b
    binding.pry
  end
end

Frames.new.method_a
