#
# Toy program for testing binding.pry initialization
#

new_str = 'string'.gsub!(/str/) do |match|
  binding.pry
end

new_str
