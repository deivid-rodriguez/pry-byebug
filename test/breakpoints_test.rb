require 'test_helper'

#
# Tests for pry-byebug breakpoints.
#
class BreakpointsTestGeneral < MiniTest::Spec
  #
  # Minimal dummy example class.
  #
  class Tester
    def self.class_method; end
    def instance_method; end
  end

  def breakpoints_class
    Pry::Byebug::Breakpoints
  end

  def test_add_file_raises_argument_error
    Pry.stubs eval_path: 'something'
    File.stubs :exist?
    assert_raises(ArgumentError) do
      breakpoints_class.add_file('file', 1)
    end
  end

  def test_add_method_adds_instance_method_breakpoint
    Pry.stub :processor, Byebug::PryProcessor.new do
      breakpoints_class.add_method 'BreakpointsTest::Tester#instance_method'
      bp = Byebug.breakpoints.last
      assert_equal 'BreakpointsTest::Tester', bp.source
      assert_equal 'instance_method', bp.pos
    end
  end

  def test_add_method_adds_class_method_breakpoint
    Pry.stub :processor, Byebug::PryProcessor.new do
      breakpoints_class.add_method 'BreakpointsTest::Tester.class_method'
      bp = Byebug.breakpoints.last
      assert_equal 'BreakpointsTest::Tester', bp.source
      assert_equal 'class_method', bp.pos
    end
  end
end

#
# Some common specs for breakpoints
#
module BreakpointSpecs
  def test_shows_breakpoint_enabled
    @output.string.must_match @regexp
  end

  def test_shows_breakpoint_hit
    result = @output.string
    result.must_match(@regexp)
    match = result.match(@regexp)
    result.must_match(/^  Breakpoint #{match[:id]}\. First hit/)
  end

  def test_shows_breakpoint_line
    @output.string.must_match(/\=> \s*#{@line}:/)
  end
end

#
# Tests for breakpoint commands
#
class BreakpointsTestCommands < Minitest::Spec
  let(:break_first_file) { test_file('break1') }
  let(:break_second_file) { test_file('break2') }

  before do
    Pry.color = false
    Pry.pager = false
    Pry.hooks = Pry::DEFAULT_HOOKS
    @input = InputTester.new 'break --delete-all'
    @output = StringIO.new
  end

  after do
    clean_remove_const(:Break1Example)
    clean_remove_const(:Break2Example)
  end

  describe 'Set Breakpoints' do
    describe 'by line number' do
      before do
        @input.add('break 6')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 6
        @regexp = /  Breakpoint (?<id>\d+): #{break_first_file} @ 6 \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'by method_id' do
      before do
        @input.add('break Break1Example#a')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 5
        @regexp = /  Breakpoint (?<id>\d+): Break1Example#a \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'by method_id when its a bang method' do
      before do
        @input.add('break Break1Example#c!')
        redirect_pry_io(@input, @output) { load break_first_file }
        @line = 15
        @regexp = /  Breakpoint (?<id>\d+): Break1Example#c! \(Enabled\)/
      end

      include BreakpointSpecs
    end

    describe 'by method_id within context' do
      before do
        @input.add('break #b')
        redirect_pry_io(@input, @output) { load break_second_file }
        @line = 7
        @regexp = /  Breakpoint (?<id>\d+): Break2Example#b \(Enabled\)/
      end

      include BreakpointSpecs
    end
  end

  describe 'List breakpoints' do
    before do
      @input.add('break #b', 'breakpoints')
      redirect_pry_io(@input, @output) { load break_second_file }
    end

    it 'shows all breakpoints' do
      @output.string.must_match(/Yes \s*Break2Example#b/)
    end

    it 'properly aligns headers' do
      width = Byebug.breakpoints.last.id.to_s.length
      @output.string.must_match(/   {#{width - 1}}# Enabled At/)
      @output.string.must_match(/  \d{#{width}} Yes     Break2Example#b/)
    end
  end

  describe 'Break inside multiline input' do
    let(:evaled_source) do
      <<-RUBY
        2.times do |i|
          break 16 if i > 0
        end
      RUBY
    end

    before do
      @input.add(evaled_source)

      redirect_pry_io(@input, @output) { load break_first_file }
    end

    it 'is ignored' do
      Pry::Byebug::Breakpoints.count.must_equal(0)
    end

    it 'lets input be properly evaluated' do
      @output.string.must_match(/=> 16/)
    end
  end
end
