require 'test_helper'

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
# Tests for pry-byebug stepping commands.
#
class SteppingTest < MiniTest::Spec
  let(:step_file) { test_file('stepping') }

  before do
    Object.send :remove_const, :SteppingExample if defined? SteppingExample
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
end
