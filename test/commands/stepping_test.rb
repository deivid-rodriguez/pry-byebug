# frozen_string_literal: true

require "test_helper"

#
# Tests for pry-byebug stepping commands
#
class SteppingTest < MiniTest::Test
  def setup
    super

    @output = StringIO.new
    @input = InputTester.new("break --delete-all")
  end

  def teardown
    clean_remove_const(:SteppingExample)

    super
  end
end

#
# Tests the step command without arguments
#
class StepCommandSingleStepTest < SteppingTest
  def setup
    super

    @input.add("step")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_stops_at_the_next_statement
    assert_match(/\=> \s*9:/, @output.string)
  end
end

#
# Tests the step command with a step argument
#
class StepCommandMultipleStepTest < SteppingTest
  def setup
    super

    @input.add("step 2")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_stops_a_correct_number_of_steps_after
    assert_match(/\=> \s*14:/, @output.string)
  end
end

#
# Tests the next command without arguments
#
class NextCommandSingleStepTest < SteppingTest
  def setup
    super

    @input.add("next")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_stops_at_the_next_line_in_the_current_frame
    assert_match(/\=> \s*26:/, @output.string)
  end
end

#
# Tests the next command with an argument
#
class NextCommandMultipleStepTest < SteppingTest
  def setup
    super

    @input.add("next 2")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_advances_the_correct_number_of_lines
    assert_match(/\=> \s*27:/, @output.string)
  end
end

#
# Tests that the next Ruby keyword does not conflict with the next command
#
class NextInsideMultilineInput < SteppingTest
  def setup
    super

    @input.add(
      "2.times do |i|",
      "if i == 0",
      "next",
      "end",
      "break 1001 + i",
      "end"
    )

    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_it_is_ignored
    assert_match(/\=> \s*8:/, @output.string)
    refute_match(/\=> \s*26:/, @output.string)
  end

  def test_lets_input_be_properly_evaluated
    assert_match(/=> 1002/, @output.string)
  end
end

#
# Tests the finish command
#
class FinishCommand < SteppingTest
  def setup
    super

    @input.add("break 21", "continue", "finish")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_advances_until_the_end_of_the_current_frame
    assert_match(/\=> \s*17:/, @output.string)
  end
end

#
# Tests the continue command without arguments
#
class ContinueCommandWithoutArguments < SteppingTest
  def setup
    super

    @input.add("break 16", "continue")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_advances_until_the_next_breakpoint
    assert_match(/\=> \s*16:/, @output.string)
  end
end

#
# Tests the continue command with a line argument
#
class ContinueCommandWithALineArgument < SteppingTest
  def setup
    super

    @input.add("continue 16")
    redirect_pry_io(@input, @output) { load test_file("stepping") }
  end

  def test_advances_until_the_specified_line
    assert_match(/\=> \s*16:/, @output.string)
  end
end
