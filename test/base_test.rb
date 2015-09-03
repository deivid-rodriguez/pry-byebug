require 'test_helper'

#
# Checks current pry-byebug's context.
#
class BaseTest < MiniTest::Spec
  def test_main_file_context
    Pry.stub :eval_path, '<main>' do
      assert PryByebug.file_context?(TOPLEVEL_BINDING)
    end
  end

  def test_other_file_context
    Pry.stub :eval_path, 'something' do
      refute PryByebug.file_context?(TOPLEVEL_BINDING)
    end
  end
end

#
# Tests binding.pry stops at that line with PryByebug.break_behavior = :pry
#

class TestStopsOnBinding < MiniTest::Spec
  def setup
    super
    PryByebug.binding_behavior = :pry
    @output = StringIO.new
    @input = InputTester.new('')
    redirect_pry_io(@input, @output) { load test_file('last_line') }
  end

  def test_stops_on_binding
    assert_match(/\=> \s*2:/, @output.string)
  end

  def teardown
    PryByebug.binding_behavior = :byebug
  end
end
