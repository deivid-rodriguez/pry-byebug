require 'pry/test/helper'
require 'minitest/autorun'
require 'pry-byebug'
require 'mocha/setup'

#
# Set I/O streams. Out defaults to an anonymous StringIO.
#
def redirect_pry_io(new_in, new_out = StringIO.new)
  old_in, old_out = Pry.input, Pry.output
  Pry.input, Pry.output = new_in, new_out
  begin
    yield
  ensure
    Pry.input, Pry.output = old_in, old_out
  end
end

def test_file(name)
  (Pathname.new(__FILE__) + "../examples/#{name}.rb").cleanpath.to_s
end

#
# Simulate pry-byebug's input for testing
#
class InputTester
  def initialize(*actions)
    @orig_actions = actions.dup
    @actions = actions
  end

  def readline(*)
    @actions.shift
  end
end
