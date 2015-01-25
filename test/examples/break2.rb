#
# Another toy example for testing break commands.
#
class Break2Example
  def a
    binding.pry
    z = 2
    z + b
  end

  def b
    c
  end

  def c
    z = 4
    z + 5
  end
end

Break2Example.new.a
