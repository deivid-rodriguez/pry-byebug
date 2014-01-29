require 'test_helper'

class CommandsTest < MiniTest::Spec
  let(:step_file) do
    (Pathname.new(__FILE__) + "../examples/stepping.rb").cleanpath.to_s
  end

  let(:break_first_file) do
    (Pathname.new(__FILE__) + "../examples/break1.rb").cleanpath.to_s
  end

  let(:break_second_file) do
    (Pathname.new(__FILE__) + "../examples/break2.rb").cleanpath.to_s
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
        @input = InputTester.new 'step'
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
        @input = InputTester.new 'step 2'
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
        @input = InputTester.new 'next'
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
        @input = InputTester.new 'next 2'
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 20:/
      end
    end
  end

  describe 'Set Breakpoints' do
    before do
      @input = InputTester.new 'break --delete-all'
      redirect_pry_io(@input, @output) do
        load break_first_file
      end
      @output = StringIO.new
    end

    describe 'set by line number' do
      before do
        @input = InputTester.new 'break 3'
        redirect_pry_io(@input, @output) do
          load break_first_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: #{break_first_file} @ 3 \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): #{break_first_file} @ 3 \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=> 3:/
      end
    end

    describe 'set by method_id' do
      before do
        @input = InputTester.new 'break BreakExample#a'
        redirect_pry_io(@input, @output) do
          load break_first_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: BreakExample#a \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): BreakExample#a \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=> 4:/
      end

      describe 'when its a bang method' do
        before do
          @input = InputTester.new 'break BreakExample#c!'
          redirect_pry_io(@input, @output) do
            load break_first_file
          end
        end

        it 'shows breakpoint enabled' do
          @output.string.must_match /^Breakpoint [\d]+: BreakExample#c! \(Enabled\)/
        end

        it 'shows breakpoint hit' do
          @output.string =~ /^Breakpoint ([\d]+): BreakExample#c! \(Enabled\)/
          @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
        end

        it 'shows breakpoint line' do
          @output.string.must_match /\=> 14:/
        end
      end
    end

    describe 'set by method_id within context' do
      before do
        @input = InputTester.new 'break #b'
        redirect_pry_io(@input, @output) do
          load break_second_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: BreakExample#b \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): BreakExample#b \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=>  8:/
      end
    end

  end
end

