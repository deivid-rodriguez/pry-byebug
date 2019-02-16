# frozen_string_literal: true

require "test_helper"

#
# Some common specs for breakpoints
#
module BreakpointSpecs
  def test_shows_breakpoint_enabled
    assert_match @regexp, @output.string
  end

  def test_shows_breakpoint_hit
    assert_match @regexp, @output.string

    match = @output.string.match(@regexp)
    assert_match(/^  Breakpoint #{match[:id]}\. First hit/, @output.string)
  end

  def test_shows_breakpoint_line
    assert_match(/\=> \s*#{@line}:/, @output.string)
  end
end

#
# Tests for breakpoint commands
#
class BreakpointsTest < Minitest::Test
  def setup
    super

    @input = InputTester.new "break --delete-all"
    @output = StringIO.new
  end

  def teardown
    super

    clean_remove_const(:Break1Example)
    clean_remove_const(:Break2Example)
  end

  def width
    Byebug.breakpoints.last.id.to_s.length
  end
end

#
# Tests setting a breakpoint by line number
#
class SettingBreakpointsTestByLineNumber < BreakpointsTest
  def setup
    super

    @input.add("break 8")
    redirect_pry_io(@input, @output) { load test_file("break1") }
    @line = 8
    @regexp = /  Breakpoint (?<id>\d+): #{test_file('break1')} @ 8 \(Enabled\)/
  end

  include BreakpointSpecs
end

#
# Tests setting a breakpoint in a method
#
class SettingBreakpointsTestByMethodId < BreakpointsTest
  def setup
    super

    @input.add("break Break1Example#a")
    redirect_pry_io(@input, @output) { load test_file("break1") }
    @line = RUBY_VERSION >= "2.5.0" ? 8 : 7
    @regexp = /  Breakpoint (?<id>\d+): Break1Example#a \(Enabled\)/
  end

  include BreakpointSpecs
end

#
# Tests setting a breakpoint in a bang method
#
class SettingBreakpointsTestByMethodIdForBangMethods < BreakpointsTest
  def setup
    super

    @input.add("break Break1Example#c!")
    redirect_pry_io(@input, @output) { load test_file("break1") }
    @line = RUBY_VERSION >= "2.5.0" ? 18 : 17
    @regexp = /  Breakpoint (?<id>\d+): Break1Example#c! \(Enabled\)/
  end

  include BreakpointSpecs
end

#
# Tests setting a breakpoint in a (non fully qualified) method
#
class SettingBreakpointsTestByMethodIdWithinContext < BreakpointsTest
  def setup
    super

    @input.add("break #b")
    redirect_pry_io(@input, @output) { load test_file("break2") }
    @line = 9
    @regexp = /  Breakpoint (?<id>\d+): Break2Example#b \(Enabled\)/
  end

  include BreakpointSpecs
end

#
# Tests listing breakpoints
#
class ListingBreakpoints < BreakpointsTest
  def setup
    super

    @input.add("break #b", "break")
    redirect_pry_io(@input, @output) { load test_file("break2") }
  end

  def test_shows_all_breakpoints
    assert_match(/Yes \s*Break2Example#b/, @output.string)
  end

  def test_properly_displays_breakpoint_list
    assert_match(/   {#{width - 1}}# Enabled At/, @output.string)
    assert_match(/  \d{#{width}} Yes     Break2Example#b/, @output.string)
  end
end

#
# Tests disabling breakpoints
#
class DisablingBreakpoints < BreakpointsTest
  def setup
    super

    @input.add("break #b", "break --disable-all")
    redirect_pry_io(@input, @output) { load test_file("break2") }
  end

  def test_shows_breakpoints_as_disabled
    assert_match(/   {#{width - 1}}# Enabled At/, @output.string)
    assert_match(/  \d{#{width}} No      Break2Example#b/, @output.string)
  end
end

#
# Tests that the break Ruby keyword does not conflict with the break command
#
class BreakInsideMultilineInput < BreakpointsTest
  def setup
    super

    @input.add("2.times do |i|", "break 18 if i > 0", "end")

    redirect_pry_io(@input, @output) { load test_file("break1") }
  end

  def test_it_is_ignored
    assert_equal 0, Pry::Byebug::Breakpoints.size
  end

  def test_lets_input_be_properly_evaluated
    assert_match(/=> 18/, @output.string)
  end
end
