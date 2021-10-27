# frozen_string_literal: true

require 'socket'

class Server < TCPServer
  private
  def initialize(environment, bot)
    # Server stuff
    @hostname = environment.get('SERVER_HOSTNAME')
    @port = environment.get('SERVER_PORT')
    super(@hostname, @port.to_i)
    # Reference to bot
    @bot = bot
    run
  end

  def run
    # child_pid = fork do
    fork do
      loop do
        client = accept
        while resp = client.gets
          bytes = resp.chomp.split(';')
          bytes = bytes.map { |s| s.to_i }
          type, msg, errno = bytes.pack('U*').split('|')
          @bot.alert(type, msg, errno.to_i)
        end
        client.close
      end
    end
  end
end