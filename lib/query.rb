# frozen_string_literal: true

require 'httparty'

class HTTPError < StandardError
end

# HTTP query forge class for Root-Me and Octoprint APIs.
class QueryForge
  def check_rootme
    begin
        new_scores = pull_scores
    rescue JSON::ParserError
        # Happens if 429 Too Many Requests
        $stderr.puts "API Root-Me - Too many requests"
        return nil
    end
    buffer = []
    @scores.each do |player, _challs|
      (new_scores[player] - @scores[player]).each do |chall|
        cdata = pull_chall_info(chall[:id_challenge])
        str = "🚩 `[#{cdata[:rubrique]}]` #{player} just flagged "
        str += "**#{cdata[:titre]}** (#{cdata[:score]} points)" if cdata[:score] != '0'
        buffer.append("#{str} !")
      end
    end
    @scores = new_scores
    buffer.length.positive? ? buffer.join('\n') : nil
  end

  def check_printing
    if printer_printing? != @printing
        str = "The printer has #{@printing ? 'stopped' : 'started'} printing!"
        @printing = !@printing
        str
    end
  end

  private

  def initialize(environment)
    # Root-Me
    @rootme_base_url = 'https://api.www.root-me.org'
    @rootme_key = environment.get('ROOTME_APIKEY')
    @scores = pull_scores
    # Octoprint
    @octoprint_base_url = 'https://www.chocorp.net:8080/api'
    @octoprint_key = environment.get('OCTOPRINT_APIKEY')
    @printing = printer_printing?

  end

  def pull_scores
    url = "#{@rootme_base_url}/auteurs"
    scores = { 'mulog': 62_550, 'beubz': 469_552, 'Mcdostone': 120_259 }
    scores.each do |k, v|
      json = get("#{url}/#{v}", cookie: "api_key=#{@rootme_key}")
      scores[k] = json[:validations]
    end
    scores
  end

  def pull_chall_info(cid)
    url = "#{@rootme_base_url}/challenges/#{cid}"
    get(url, cookie: "api_key=#{@rootme_key}")
  end

  def printer_printing?
    url = "#{@octoprint_base_url}/connection"
    headers = { 'X-Api-Key': "#{@octoprint_key}",
                'Host': 'www.chocorp.net:8080' }
    get(url, headers)[:current][:state] === 'Printing'
  end

  def get(url, headers = {}, cookie = '')
    if cookie != ''
        headers['Cookie'] = cookie
    end
    tries = 0
    while tries < 5
        begin
            response = HTTParty.get(url, format: :plain, :headers => headers)
            return JSON.parse response, symbolize_names: true
        rescue Errno::ECONNRESET
            tries += 1
        end
    end
    raise HTTPError "Too many failed HTTP requests"
  end
end
