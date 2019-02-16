# frozen_string_literal: true

require "test_helper"
require "stringio"

#
# Tests for pry-byebug frame commands.
#
class FramesTest < MiniTest::Spec
  let(:output) { StringIO.new }

  after { clean_remove_const(:FramesExample) }

  describe "Up command" do
    let(:input) { InputTester.new("up", "down") }

    before do
      redirect_pry_io(input, output) { load test_file("frames") }
    end

    it "shows current line" do
      output.string.must_match(/=> \s*8: \s*method_b/)
    end
  end

  describe "Down command" do
    let(:input) { InputTester.new("up", "down") }

    before do
      redirect_pry_io(input, output) { load test_file("frames") }
    end

    it "shows current line" do
      output.string.must_match(/=> \s*13: \s*end/)
    end
  end

  describe "Frame command" do
    before do
      redirect_pry_io(input, output) { load test_file("frames") }
    end

    describe "jump to frame 1" do
      let(:input) { InputTester.new("frame 1", "frame 0") }

      it "shows current line" do
        output.string.must_match(/=> \s*8: \s*method_b/)
      end
    end

    describe "jump to current frame" do
      let(:input) { InputTester.new("frame 0") }

      it "shows current line" do
        output.string.must_match(/=> \s*13: \s*end/)
      end
    end
  end

  describe "Backtrace command" do
    let(:input) { InputTester.new("backtrace") }

    before do
      @stdout, @stderr = capture_subprocess_io do
        redirect_pry_io(input) { load test_file("frames") }
      end
    end

    it "shows a backtrace" do
      frames = @stdout.split("\n")

      assert_match(/\A--> #0  FramesExample\.method_b at/, frames[0])
      assert_match(/\A    #1  FramesExample\.method_a at/, frames[1])
      assert_match(/\A    #2  <top \(required\)> at/, frames[2])
    end
  end
end
