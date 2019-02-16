# frozen_string_literal: true

require "test_helper"

#
# Tests for pry-byebug's processor.
#
class ProcessorTest < Minitest::Spec
  let(:output) { StringIO.new }

  describe "Initialization" do
    let(:input) { InputTester.new }

    describe "normally" do
      let(:source_file) { test_file("stepping") }

      before do
        redirect_pry_io(input, output) { load source_file }
      end

      after { clean_remove_const(:SteppingExample) }

      it "stops execution at the first line after binding.pry" do
        output.string.must_match(/\=>  8:/)
      end
    end

    describe "at the end of block/method call" do
      let(:source_file) { test_file("deep_stepping") }

      before do
        redirect_pry_io(input, output) { load source_file }
      end

      it "stops execution at the first line after binding.pry" do
        output.string.must_match(/\=>  9:/)
      end
    end
  end
end
