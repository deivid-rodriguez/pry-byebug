binding.pry

#
# A toy example for testing break commands.
#
class Break1Example
  undef a if method_defined? :a
  undef b if method_defined? :b
  undef c! if method_defined? :c!

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

Break1Example.new.a
