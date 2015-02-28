#
# A toy example for testing break commands.
#
class Break1Example
  def a
    z = 2
    z + b
  end

  def b
    z = 5
    z + c!
  end

  def c!
    z = 4
    z
  end
end

binding.pry

Break1Example.new.a
