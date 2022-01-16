# frozen_string_literal: true

require_relative '../query_forge'

# Queries several information from Octoprint api
class Plugin
  private

  def initialize(scheduler, bot)
    @printing = false
    @octoprint_url = ENV['OCTOPRINT_URL']
    @octoprint_key = ENV['OCTOPRINT_APIKEY']

    scheduler.every '30' do
      is_printing = printing?
      if is_printing != @printing
        action = @printing ? 'stopped' : 'started'
        bot.info "The printer has #{action} printing!"
      end
      @printing = is_printing
    end
  end

  def printing?
    url = "#{@octoprint_base_url}/connection"
    headers = { 'X-Api-Key': @octoprint_key.to_s,
                Host: @octoprint_url.gsub(%r{https?://}, '') }
    begin
      response = QueryForge.get(url, headers)
      return false if response.nil?

      response[:current][:state] == 'Printing'
    rescue Errno::ECONNREFUSED # PI is off or octoprint crashed
      false
    end
  end

  def stop
  end
end
