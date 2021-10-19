# frozen_string_literal: true

require 'discordrb'

require_relative 'env/env'
require_relative 'query'
require_relative 'server'

# Discord Bot which PM its owner.
class ChocoBot < Discordrb::Bot
  def alert(type, msg, errno=0)
    content = "`[#{type}]` #{msg}"
    error = ! [0, nil].include?(errno)
    say(content, error)
  end

  private
  def initialize
    # utils
    @env = Environment.new
    @qforge = QueryForge.new @env
    # init
    super(token: @env.get('DISCORD_TOKEN'))
    owner_id = @env.get('OWNER_ID')
    @owner = user(owner_id.to_i)
    @error = nil
    @server = Server.new(@env, self)
  end

  def say(msg, err=false)
    return if msg.nil?
    if err == 1 or err == true
      msg = "⚠️ #{msg} ⚠️"
    elsif err == 2
      msg = "⛔ #{msg} ⛔"
    elsif err == 3
      msg = "❓ #{msg} ❓"
    end

    begin
      @owner.pm(msg)
    rescue RestClient::BadRequest => e
      warn "Unable to send: #{msg}"
      warn "Error: #{e.to_s}"
    end
  end

  def warn(msg)
    say(msg, true)
  end


  public
  def run
    begin
      self.ready do
        say('⚙️ I\'m up!')
      end
      super.run(true)

      # Main loop
      loop do
        for func in ['printing', 'rootme']
          begin
            method = "check_#{func}"
            resp = @qforge.public_send(method)
            say(resp)
          rescue Exception => e
            warn("Error when pulling `#{func}` data:\n#{e.to_s}")
          end
        end
        sleep @env.get('SLEEP_TIME').to_i
      end
    rescue Interrupt
      p 'Exiting'
    ensure
      say('💤 Going down!')
      stop
    end
  end
end
