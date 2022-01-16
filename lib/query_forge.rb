# frozen_string_literal: true

require 'httparty'

class HTTPError < StandardError
end

# HTTP query forge class
class QueryForge
  # GET request, return plain response
  def self.get(url, options = {})
    headers = {}
    headers ||= options[:headers]
    headers['Cookie'] = options[:cookie] if options[:cookies]

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
      end
    end
    raise HTTPError, "HTTP request to #{url} failed too many times"
  end

  # GET request, return response as JSON
  def self.get_as_json(url, options = {})
    resp = get(url, options)
    JSON.parse resp
  end
end
