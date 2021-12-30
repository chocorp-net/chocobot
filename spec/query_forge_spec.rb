# frozen_string_literal: true

require 'query_forge'
require 'webmock/rspec'
WebMock.disable_net_connect!

RSpec.describe QueryForge do
  context 'when the response is plain text' do
    forge = described_class.new
    it 'performs GET' do
      stub_request(:get, 'https://example.com')
        .to_return(body: 'abc')
      expect(forge.get('https://example.com')).to eq 'abc'
    end

    it 'performs GET with headers' do
      stub_request(:get, 'https://example.com')
        .with(headers: { test: 'ok' }).to_return(body: 'abc')
      expect(forge.get('https://example.com', { test: 'ok' })).to eq 'abc'
    end

    it 'performs GET with cookies' do
      stub_request(:get, 'https://example.com')
        .with(headers: { Cookie: 'test=ok' })
        .to_return(body: 'abc')
      expect(forge.get('https://example.com',
                       cookie: 'test=ok')).to eq 'abc'
    end
  end

  context 'when the response is JSON' do
    forge = described_class.new
    it 'performs GET' do
      stub_request(:get, 'https://example.com')
        .to_return(body: '{"abc":"ok"}')
      expect(forge.get_as_json('https://example.com'))
        .to eq(JSON.parse('{"abc":"ok"}'))
    end

    it 'performs GET with headers' do
      stub_request(:get, 'https://example.com')
        .with(headers: { test: 'ok' }).to_return(body: '{"abc":"ok"}')
      expect(forge.get_as_json('https://example.com', { test: 'ok' }))
        .to eq(JSON.parse('{"abc":"ok"}'))
    end

    it 'performs GET with cookies' do
      stub_request(:get, 'https://example.com')
        .with(headers: { Cookie: 'test=ok' })
        .to_return(body: '{"abc":"ok"}')
      expect(forge.get_as_json('https://example.com', cookie: 'test=ok'))
        .to eq(JSON.parse('{"abc":"ok"}'))
    end
  end
end
