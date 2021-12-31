# frozen_string_literal: true

require 'discordrb'

require_relative 'env'

# Discord Bot which PM its owner.
class ChocoBot < Discordrb::Bot
  private
  def initialize(env)
    @env = env
    owner_id = @env.get('DISCORD_OWNER_ID')
    super(token: @env.get('DISCORD_TOKEN'))
    @owner = user(owner_id.to_i)
    @dev = @env.get('CHOCOBOT_ENV').upcase != 'PRODUCTION'
  end

  # Send data to owner after formatting.
  def send(data)
    data.gsub!(/<\/?b>/, '**')
    data.gsub!(/<\/?i>/, '*')
    say(data)
  end

  public
  # Start the Discord bot and plugins clock.
  def run
    super.run true
    info('⚙️ I\'m up!')

    # Look for plugins
    # TODO
    # Run their stuff
    # TODO

    stop
  end

  # Debug messages.
  # Only printed in development environment.
  def debug(msg)
    if @dev
      msg = "🔨 #{msg}"
      send(msg)
    end
  end

  # Basic messages. Always displayed.
  def info(msg)
    msg = "ℹ️ #{msg}"
    send(msg)
  end

  # Warnings.
  def warn(msg)
    msg = "⚠️ #{msg}"
    send(msg)
  end

  # Critical alerts.
  def critical(msg)
    msg =  "⛔ #{msg}"
    send(msg)
  end

  # Messages with unknown level. Always print.
  def unknown(msg)
    msg = "❓ #{msg}"
    send(msg)
  end

  # Traces
  def error(err)
    if @dev
      msg = "```\n#{err}\n```"
      send(msg)
    end
  end
end