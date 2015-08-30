#
# Toy class for testing frame commands
#
class FramesExample
  def method_a
    method_b
  end

  def method_b
    pry_byebug
  end
end

FramesExample.new.method_a
