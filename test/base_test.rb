require 'test_helper'

class BaseTest < MiniTest::Spec
  def test_main_file_context
    Pry.stubs eval_path: "<main>"
    assert PryByebug.check_file_context(TOPLEVEL_BINDING)
  end

  def test_other_file_context
    Pry.stubs eval_path: "something"
    refute PryByebug.check_file_context(TOPLEVEL_BINDING)
  end
end

