class BreakExample
  def a
    binding.pry
    z = 2
    b
  end

  def b
    c
  end

  def c
    z = 4
    5
  end
end

BreakExample.new.a
