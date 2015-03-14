require 'test_helper'

#
# Tests for pry-byebug frame commands.
#
class FramesTest < MiniTest::Spec
  let(:output) { StringIO.new }

  before do
    Pry.color, Pry.pager, Pry.hooks = false, false, Pry::DEFAULT_HOOKS
  end

  describe 'Up command' do
    let(:input) { InputTester.new('up', 'down') }

    before do
      redirect_pry_io(input, output) { load test_file('frames') }
    end

    it 'shows current line' do
      output.string.must_match(/=> \s*6: \s*method_b/)
    end
  end

  describe 'Down command' do
    let(:input) { InputTester.new('up', 'down') }

    before do
      redirect_pry_io(input, output) { load test_file('frames') }
    end

    it 'shows current line' do
      output.string.must_match(/=> \s*11: \s*end/)
    end
  end

  describe 'Frame command' do
    before do
      redirect_pry_io(input, output) { load test_file('frames') }
    end

    describe 'jump to frame 1' do
      let(:input) { InputTester.new('frame 1', 'frame 0') }

      it 'shows current line' do
        output.string.must_match(/=> \s*6: \s*method_b/)
      end
    end

    describe 'jump to current frame' do
      let(:input) { InputTester.new('frame 0') }

      it 'shows current line' do
        output.string.must_match(/=> \s*11: \s*end/)
      end
    end
  end
end
