# frozen_string_literal: true

require 'socket'

# Runs a TCP server which receives Nagios alerts
class Plugin
  private

  # Custom TCP server
  class Server < TCPServer
    private

    def initialize
      @hostname = ENV['NAGIOS_SERVER_HOSTNAME']
      @port = ENV['NAGIOS_SERVER_PORT']
      super(@hostname, @port.to_i)
      run
    end

    def run
      @child_pid = fork do
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

    def stop
      # For now, just kill the child lol
      system "kill -9 #{@child_pid}"
    end
  end

  def initialize(scheduler, bot)
    @server = Server.new
  end

  def stop
    @server.stop
  end
end
