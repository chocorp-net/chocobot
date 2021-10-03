# frozen_string_literal: true

require 'discordrb'

# Discord Bot with easy access to pm owner.
class ChocoBot < Discordrb::Bot
  def initialize(environment)
    super(token: environment.get('DISCORD_TOKEN'))
    owner_id = environment.get('OWNER_ID')
    @owner = user(owner_id.to_i)
  end

  def pm(msg)
    return if msg.nil?

    begin
      @owner.pm(msg)
    rescue RestClient::BadRequest
      warn "Unable to send: #{msg}"
    end
  end
end
