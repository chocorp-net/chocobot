# frozen_string_literal: true

require 'httparty'

class HTTPError < StandardError
end

# HTTP query forge class
class QueryForge
  # GET request, return plain response
  def get(url, headers = {}, cookie = '')
    headers['Cookie'] = cookie if cookie != ''
    tries = 0
    while tries < 5
      begin
        resp = HTTParty.get(url, format: :plain, headers: headers)
        raise HTTPError if resp.body.nil? || resp.body.empty?

        return resp.body
      rescue Errno::ECONNRESET, Errno::ENETUNREACH, Net::OpenTimeout, HTTPError
        sleep 1
        tries += 1
      end
    end
    warn "Too many failed HTTP requests (#{url})"
  end

  # GET request, return response as JSON
  def get_as_json(url, headers = {}, cookie = '')
    JSON.parse get(url, headers, cookie)
  end
end
