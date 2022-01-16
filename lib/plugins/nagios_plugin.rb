# frozen_string_literal: true

require 'socket'

# Runs a TCP server which receives Nagios alerts
class Plugin
  def stop
  end

  private

  # Custom TCP server
  class Server < TCPServer
    private

    def initialize(bot)
      @bot = bot
      @hostname = ENV['NAGIOS_SERVER_HOSTNAME']
      @port = ENV['NAGIOS_SERVER_PORT']
      super(@hostname, @port.to_i)
      run
    end

    def run
      @child_pid = fork do
        begin
          loop do
            client = accept
            while resp = client.gets
              bytes = resp.chomp.split(';')
              bytes = bytes.map { |s| s.to_i }
              type, msg, errno = bytes.pack('U*').split('|')
              errno = errno.to_i
              content = "`[#{type}]` #{msg}"
              if errno == 1
                @bot.warning content
              elsif errno == 2
                @bot.critical content
              elsif errno == 3
                @bot.unknown content
              else
                warn "[Nagios] Unknown errno #{errno}"
              end
            end
            client.close
          end
        rescue Interrupt
          # Nothing to do
          exit 0
        end
      end
    end
  end

  def initialize(scheduler, bot)
    @server = Server.new bot
  end
end
