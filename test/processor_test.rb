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
      @input = InputTester.new
      @output = StringIO.new
      redirect_pry_io(@input, @output) { load step_file }
    end

    it 'stops execution at the first line after binding.pry' do
      @output.string.must_match(/\=>  6:/)
    end
  end
end
