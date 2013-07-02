require 'test_helper'

class CommandsTest < MiniTest::Spec
  let(:step_file) do
    (Pathname.new(__FILE__) + "../examples/stepping.rb").cleanpath.to_s
  end

  before do
    Pry.color = false
    Pry.pager = false
    Pry.hooks = Pry::DEFAULT_HOOKS
    @output = StringIO.new
  end

  describe 'Step Command' do
    describe 'single step' do
      before do
        @input = InputTester.new('step')
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 3:/
      end
    end

    describe 'multiple step' do
      before do
        @input = InputTester.new('step 2')
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 4:/
      end
    end
  end

  describe 'Next Command' do
    describe 'single step' do
      before do
        @input = InputTester.new('next')
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 3:/
      end
    end

    describe 'multiple step' do
      before do
        @input = InputTester.new('next 2')
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 20:/
      end
    end
  end

end

