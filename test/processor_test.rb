require 'test_helper'

class ProcessorTest < Minitest::Test
  
  def test_new
    assert PryByebug::Processor.new    
  end
  
end

