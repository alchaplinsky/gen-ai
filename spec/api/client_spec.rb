# frozen_string_literal: true

RSpec.describe GenAI::Api::Client do
  let(:url) { 'https://api.gen.ai' }
  let(:token) { 'FAKE_TOKEN' }
  let(:instance) { described_class.new(url:, token:) }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:response) { Faraday::Response.new(status: 200, body: '{"status": "ok"}') }

  before do
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:post).and_return(response)
    allow(connection).to receive(:get).and_return(response)
  end

  describe '#post' do
    subject do
      instance.post('/v1/test', { params: { text: 'TEXT' } })
    end

    it 'makes a post with correct url and body' do
      subject

      expect(connection).to have_received(:post).with('/v1/test', '{"params":{"text":"TEXT"}}')
    end

    it 'passes correct headers' do
      subject

      expect(Faraday).to have_received(:new).with({
        url:,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Authorization' => 'Bearer FAKE_TOKEN'
        }
      })
    end
  end

  describe '#get' do
    subject do
      instance.get('/v1/test', { text: 'TEXT' })
    end

    it 'makes a get with correct url and options' do
      subject

      expect(connection).to have_received(:get).with('/v1/test', {text: 'TEXT'})
    end

    it 'passes correct headers' do
      subject

      expect(Faraday).to have_received(:new).with({
        url:,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Authorization' => 'Bearer FAKE_TOKEN'
        }
      })
    end
  end
end
