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

  let(:output) { StringIO.new }

  describe 'Initialization' do
    let(:input) { InputTester.new }

    describe 'normally' do
      let(:source_file) { test_file('stepping') }

      before do
        redirect_pry_io(input, output) { load source_file }
      end

      after { clean_remove_const(:SteppingExample) }

      it 'stops execution at the first line after binding.pry' do
        output.string.must_match(/\=>  6:/)
      end
    end

    describe 'at the end of block/method call' do
      let(:source_file) { test_file('deep_stepping') }

      before do
        redirect_pry_io(input, output) { load source_file }
      end

      it 'stops execution at the first line after binding.pry' do
        output.string.must_match(/\=> 7:/)
      end
    end
  end
end
