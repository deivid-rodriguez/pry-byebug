# frozen_string_literal: true

require "test_helper"

#
# Tests for pry-byebug breakpoints.
#
class BreakpointsTestGeneral < MiniTest::Spec
  #
  # Minimal dummy example class.
  #
  class Tester
    def self.class_method; end

    def instance_method; end
  end

  def breakpoints_class
    Pry::Byebug::Breakpoints
  end

  def test_add_file_raises_argument_error
    Pry.stub :eval_path, "something" do
      assert_raises(ArgumentError) { breakpoints_class.add_file("file", 1) }
    end
  end

  def test_add_method_adds_instance_method_breakpoint
    breakpoints_class.add_method "BreakpointsTest::Tester#instance_method"
    bp = Byebug.breakpoints.last

    assert_equal "BreakpointsTest::Tester", bp.source
    assert_equal "instance_method", bp.pos
  end

  def test_add_method_adds_class_method_breakpoint
    breakpoints_class.add_method "BreakpointsTest::Tester.class_method"
    bp = Byebug.breakpoints.last

    assert_equal "BreakpointsTest::Tester", bp.source
    assert_equal "class_method", bp.pos
  end
end
