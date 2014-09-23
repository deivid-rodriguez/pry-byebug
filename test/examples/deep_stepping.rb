#
# Toy program for testing binding.pry initialization
#

new_str = 'string'.gsub!(/str/) do |_|
  binding.pry
end

new_str
