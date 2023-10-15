# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#chat' do
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    subject { instance.chat('Hello') }

    context 'with openai provider' do
      let(:provider) { :openai }
      let(:cassette) { 'openai/complete/default_prompt' }

      it 'returns completions' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first).to eq({
                                        'content' => 'Hi there! How can I assist you today?',
                                        'role' => 'assistant'
                                      })
        end
      end
    end

    context 'with google_palm provider' do
      let(:provider) { :google_palm }
      let(:cassette) { 'google/complete/default_prompt' }

      it 'returns completions' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first).to eq({
                                        'content' => 'Hello! How can I help you today?',
                                        'author' => '1'
                                      })
        end
      end
    end

    context 'with unsupported provider' do
      let(:provider) { :monster_ai }

      it 'raises an GenAI::UnsupportedProvider error' do
        expect { subject }.to raise_error(GenAI::UnsupportedProvider, /Unsupported LLM provider 'monster_ai'/)
      end
    end
  end
end
