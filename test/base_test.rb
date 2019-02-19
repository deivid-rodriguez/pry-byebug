# frozen_string_literal: true

require "test_helper"

#
# Checks current pry-byebug's context.
#
class BaseTest < MiniTest::Spec
  def test_main_file_context
    Pry.stub :eval_path, "<main>" do
      assert PryByebug.file_context?(TOPLEVEL_BINDING)
    end
  end

  def test_other_file_context
    Pry.stub :eval_path, "something" do
      refute PryByebug.file_context?(TOPLEVEL_BINDING)
    end
  end
end
