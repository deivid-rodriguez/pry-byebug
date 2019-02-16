# frozen_string_literal: true

require "socket"

client, server = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM)

Thread.new do
  while (line = server.readline)
    server.write(line)
  end
end

binding.pry
client
