#
# Toy program for testing pry_byebug initialization
#

new_str = 'string'.gsub!(/str/) do |_|
  pry_byebug
end

_foo = new_str
