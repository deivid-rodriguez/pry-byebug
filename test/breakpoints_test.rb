require 'test_helper'

class BreakpointsTest < MiniTest::Spec
  def test_add_file_raises_argument_error
    Pry.stubs eval_path: "something"
    File.stubs :exist?
    assert_raises(ArgumentError) do
      PryByebug::Breakpoints.add_file("file", 1)
    end
  end

  class Tester
    def self.class_method; end
    def instance_method; end
  end

  def test_add_method_adds_instance_method_breakpoint
    Pry.stub :processor, PryByebug::Processor.new do
      PryByebug::Breakpoints.add_method 'BreakpointsTest::Tester#instance_method'
      bp = Byebug.breakpoints.last
      assert_equal 'BreakpointsTest::Tester', bp.source
      assert_equal 'instance_method', bp.pos
    end
  end

  def test_add_method_adds_class_method_breakpoint
    Pry.stub :processor, PryByebug::Processor.new do
      PryByebug::Breakpoints.add_method 'BreakpointsTest::Tester.class_method'
      bp = Byebug.breakpoints.last
      assert_equal 'BreakpointsTest::Tester', bp.source
      assert_equal 'class_method', bp.pos
    end
  end
end
