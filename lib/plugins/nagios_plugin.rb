# frozen_string_literal: true

require 'socket'

# Runs a TCP server which receives Nagios alerts
class Plugin
  def stop; end

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

    def send_msg(content, errno)
      case errno.to_i
      when 1
        @bot.warning content
      when 2
        @bot.critical content
      when 3
        @bot.unknown content
      else
        warn "[Nagios] Unknown errno #{errno}"
      end
    end

    def run
      @child_pid = fork do
        loop do
          client = accept
          while (resp = client.gets)
            bytes = resp.chomp.split(';').map(&:to_i)
            type, msg, errno = bytes.pack('U*').split('|')
            content = "`[#{type}]` #{msg}"
            send_msg content, errno
          end
          client.close
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
