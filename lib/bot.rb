# frozen_string_literal: true

require 'discordrb'

require_relative 'plugins_loader'

# Discord Bot which PM its owner.
class ChocoBot
  private

  def initialize
    # Discord bot, runs on an independant process.
    @bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN']
    # Using DISCORD_OWNER_ID to build an object able to PM the owner.
    owner_id = ENV['DISCORD_OWNER_ID']
    @owner = @bot.user(owner_id.to_i)
    # Dev environment?
    @dev = ENV['CHOCOBOT_ENV'].upcase != 'PRODUCTION'
  end

  # Send data to owner after formatting.
  def send(data)
    data.gsub!(%r{</?b>}, '**')
    data.gsub!(%r{</?i>}, '*')
    @owner.pm(data)
  end

  public

  # Start the Discord bot and plugins clock.
  def run
    PluginsLoader.new self
    begin
      info 'Booting...'
      @bot.run
    rescue Interrupt
      info 'Shutting down...'
    rescue => e
      critical 'Unknown error happened'
      error e
      $stderr.puts "#{e.class}\n#{e.message}"
      exit 1
    end
  end

  # Debug messages.
  # Only printed in development environment.
  def debug(msg)
    return unless @dev

    msg = "🔨 #{msg}"
    send(msg)
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
    msg = "⛔ #{msg}"
    send(msg)
  end

  # Messages with unknown level. Always print.
  def unknown(msg)
    msg = "❓ #{msg}"
    send(msg)
  end

  # Traces
  def error(err)
    return unless @dev

    msg = "```#{err.class}\n#{err.message}```"
    send(msg)
  end
end
