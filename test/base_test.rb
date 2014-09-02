require 'test_helper'

#
# Checks current pry-byebug's context.
#
class BaseTest < MiniTest::Spec
  def test_main_file_context
    Pry.stubs eval_path: '<main>'
    assert PryByebug.file_context?(TOPLEVEL_BINDING)
  end

  def test_other_file_context
    Pry.stubs eval_path: 'something'
    refute PryByebug.file_context?(TOPLEVEL_BINDING)
  end
end
