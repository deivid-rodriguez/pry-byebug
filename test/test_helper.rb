# frozen_string_literal: true

require "support/coverage"

require "minitest/autorun"
require "pry-byebug"

Pry.config.color = false
Pry.config.pager = false
Pry.config.correct_indent = false

#
# Set I/O streams. Out defaults to an anonymous StringIO.
#
def redirect_pry_io(new_in, new_out = StringIO.new)
  old_in = Pry.input
  old_out = Pry.output
  Pry.input = new_in
  Pry.output = new_out
  begin
    yield
  ensure
    Pry.input = old_in
    Pry.output = old_out
  end
end

def test_file(name)
  (Pathname.new(__FILE__) + "../examples/#{name}.rb").cleanpath.to_s
end

def clean_remove_const(const)
  Object.send(:remove_const, const.to_s) if Object.send(:const_defined?, const)
end

#
# Simulate pry-byebug's input for testing
#
class InputTester
  def initialize(*actions)
    @actions = actions
  end

  def add(*actions)
    @actions += actions
  end

  def readline(*)
    @actions.shift
  end
end
