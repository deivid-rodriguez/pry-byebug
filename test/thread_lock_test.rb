# frozen_string_literal: true

require "test_helper"
require "timeout"

class ThreadLockTest < MiniTest::Spec
  let(:output) { StringIO.new }
  let(:input) { InputTester.new }

  describe "when there's another thread" do
    before do
      input.add 'client.puts("Hello")'
      input.add "IO.select([client], [], [], 1) && client.readline"

      redirect_pry_io(input, output) { load test_file("echo_thread") }
    end

    it "another thread isn't locked" do
      assert_equal "=> \"Hello\\n\"\n", output.string.lines.last
    end
  end
end
