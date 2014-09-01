require 'test_helper'

#
# Some common specs for breakpoints
#
module BreakpointSpecs
  def test_shows_breakpoint_enabled
    @output.string.must_match @regexp
  end

  def test_shows_breakpoint_hit
    match = @output.string.match(@regexp)
    @output.string.must_match(/^Breakpoint #{match[:id]}\. First hit/)
  end

  def test_shows_breakpoint_line
    @output.string.must_match(/\=> \s*#{@line}:/)
  end
end

#
# Some common specs for stepping
#
module SteppingSpecs
  def self.included(spec_class)
    spec_class.class_eval do
      it 'shows current line' do
        @output.string.must_match(/\=> \s*#{@line}:/)
      end
    end
  end
end

#
# Tests for pry-byebug commands.
#
class CommandsTest < MiniTest::Spec
  let(:step_file) { test_file('stepping') }
  let(:break_first_file) { test_file('break1') }
  let(:break_second_file) { test_file('break2') }

  before do
    Pry.color, Pry.pager, Pry.hooks = false, false, Pry::DEFAULT_HOOKS
    @output = StringIO.new
  end

  describe 'Step Command' do
    describe 'single step' do
      before do
        @input, @line = InputTester.new('step'), 7
        redirect_pry_io(@input, @output) { load step_file }
      end

      include SteppingSpecs
    end

    describe 'multiple step' do
      before do
        @input, @line = InputTester.new('step 2'), 12
        redirect_pry_io(@input, @output) { load step_file }
      end

      include SteppingSpecs
    end
  end

  describe 'Next Command' do
    describe 'single step' do
      before do
        @input, @line = InputTester.new('break --delete-all', 'next'), 6
        redirect_pry_io(@input, @output) { load step_file }
      end

      include SteppingSpecs
    end

    describe 'multiple step' do
      before do
        @input, @line = InputTester.new('break --delete-all', 'next 2'), 25
        redirect_pry_io(@input, @output) { load step_file }
      end

      include SteppingSpecs
    end
  end

  describe 'Finish Command' do
    before do
      @input = \
        InputTester.new 'break --delete-all', 'break 19', 'continue', 'finish'
      redirect_pry_io(@input, @output) { load step_file }
      @line = 15
    end

    include SteppingSpecs
  end

  describe 'Set Breakpoints' do
    before do
      @input = InputTester.new 'break --delete-all'
      redirect_pry_io(@input, @output) { load break_first_file }
    end

    describe 'set by line number' do
      before do
        @input = InputTester.new('break 7')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 7
        @regexp = /^Breakpoint (?<id>\d+): #{break_first_file} @ 7 \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'set by method_id' do
      before do
        @input = InputTester.new('break Break1Example#a')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 7
        @regexp = /Breakpoint (?<id>\d+): Break1Example#a \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'set by method_id when its a bang method' do
      before do
        @input = InputTester.new('break Break1Example#c!')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 17
        @regexp = /Breakpoint (?<id>\d+): Break1Example#c! \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'set by method_id within context' do
      before do
        @input = InputTester.new('break #b')
        redirect_pry_io(@input, @output) { load break_second_file }
        @line = 11
        @regexp = /Breakpoint (?<id>\d+): Break2Example#b \(Enabled\)/
      end

      include BreakpointSpecs
    end
  end
end
