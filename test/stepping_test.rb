require 'test_helper'

#
# Tests for pry-byebug stepping commands.
#
class SteppingTest < MiniTest::Spec
  let(:step_file) { test_file('stepping') }

  before do
    Pry.color = false
    Pry.pager = false
    Pry.hooks = Pry::DEFAULT_HOOKS
    @output = StringIO.new
    @input = InputTester.new('break --delete-all')
  end

  after { clean_remove_const(:SteppingExample) }

  describe 'Step Command' do
    describe 'single step' do
      before do
        @input.add('step')
        redirect_pry_io(@input, @output) { load step_file }
      end

      it 'stops in the next statement' do
        @output.string.must_match(/\=> \s*7:/)
      end
    end

    describe 'multiple step' do
      before do
        @input.add('step 2')
        redirect_pry_io(@input, @output) { load step_file }
      end

      it 'stops two statements after' do
        @output.string.must_match(/\=> \s*12:/)
      end
    end
  end

  describe 'Next Command' do
    describe 'single step' do
      before do
        @input.add('next')
        redirect_pry_io(@input, @output) { load step_file }
      end

      it 'goes to the next line in the current frame' do
        @output.string.must_match(/\=> \s*24:/)
      end
    end

    describe 'multiple step' do
      before do
        @input.add('next 2')
        redirect_pry_io(@input, @output) { load step_file }
      end

      it 'advances two lines in the current frame' do
        @output.string.must_match(/\=> \s*25:/)
      end
    end

    describe 'inside multiline input' do
      let(:evaled_source) do
        <<-RUBY
          s = 0

          2.times do |i|
            if i == 0
              next
            end

            s -= 1
            break s
          end
        RUBY
      end

      before do
        @input.add(evaled_source)

        redirect_pry_io(@input, @output) { load step_file }
      end

      it 'is ignored' do
        @output.string.must_match(/\=> \s*6:/)
        @output.string.wont_match(/\=> \s*24:/)
      end

      it 'lets input be properly evaluated' do
        @output.string.must_match(/=> -1/)
      end
    end
  end

  describe 'Finish Command' do
    before do
      @input.add('break 19', 'continue', 'finish')
      redirect_pry_io(@input, @output) { load step_file }
    end

    it 'advances until the end of the current frame' do
      @output.string.must_match(/\=> \s*15:/)
    end
  end
end
