#
# Another toy example for testing break commands.
#
class Break2Example
  undef a if method_defined? :a
  undef b if method_defined? :b
  undef c if method_defined? :c

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
