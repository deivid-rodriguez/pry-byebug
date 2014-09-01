binding.pry

class SteppingExample
  def method_a
    z = 2
    method_b
  end

  def method_b
    c = Math::PI/2
    c += method_c
    c + 1
  end

  def method_c
    z = 4
    5
  end
end

ex = SteppingExample.new.method_a
2.times do
  ex += 1
end

ex
