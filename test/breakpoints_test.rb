require 'test_helper'

class BreakpointsTest < Minitest::Test
  
  def test_add_raises_argument_error
    Pry.stubs eval_path: "something"
    File.stubs :exist?
    assert_raises(ArgumentError) do
      PryByebug::Breakpoints.add("file", 1)
    end
  end
  
end

