require 'test_helper'

#
# Tests for pry-byebug's processor.
#
class ProcessorTest < Minitest::Spec
  before do
    Pry.color = false
    Pry.pager = false
    Pry.hooks = Pry::DEFAULT_HOOKS
  end

  describe 'Initialization' do
    let(:step_file) { test_file('stepping') }

    before do
      Object.send :remove_const, :SteppingExample if defined? SteppingExample
      @input = InputTester.new
      @output = StringIO.new
      redirect_pry_io(@input, @output) { load step_file }
    end

    it 'stops execution at the first line after binding.pry' do
      @output.string.must_match(/\=>  6:/)
    end
  end

  describe 'Initialization at the end of block/method call' do
    let(:step_file) { test_file('deep_stepping') }

    before do
      @input, @output = InputTester.new, StringIO.new
      redirect_pry_io(@input, @output) { load step_file }
    end

    it 'stops execution at the first line after binding.pry' do
      @output.string.must_match(/\=> 7:/)
    end
  end
end
