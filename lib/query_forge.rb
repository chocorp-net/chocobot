# frozen_string_literal: true

require 'httparty'

class HTTPError < StandardError
end

# HTTP query forge class
class QueryForge
  # GET request, return plain response
  def self.get(url, headers = {}, cookie = '')
    puts 'sisi'
    headers['Cookie'] = cookie if cookie != ''
    tries = 0
    while tries < 5
      begin
        resp = HTTParty.get(url, format: :plain, headers: headers)
        raise HTTPError if resp.body.nil? || resp.body.empty?

        return resp.body
      rescue Errno::ECONNRESET, Errno::ENETUNREACH,
             Net::OpenTimeout, HTTPError # => e
        sleep 1
        tries += 1
        # raise e
      end
    end
    raise HTTPError, "HTTP request to #{url} failed"
  end

  # GET request, return response as JSON
  def self.get_as_json(url, headers = {}, cookie = '')
    resp = get(url, headers, cookie)
    JSON.parse resp
  end
end
