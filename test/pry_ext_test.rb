# frozen_string_literal: true

require "test_helper"

class PryExtTest < MiniTest::Spec
  let(:output) { StringIO.new }
  let(:input) { InputTester.new }

  describe "when disable-pry called" do
    subject { redirect_pry_io(input, output) { load test_file("multiple") } }
    before { input.add "disable-pry" }
    after { ENV.delete("DISABLE_PRY") }

    it "keeps pry's default behaviour" do
      subject
      assert_equal 1, output.string.scan(/binding\.pry/).size
    end

    it "does not start byebug" do
      Byebug.stop
      subject
      assert !Byebug.started?
    end
  end
end
