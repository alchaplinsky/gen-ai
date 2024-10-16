# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'Gemini' do
    describe '#completion' do
      let(:provider) { :gemini }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }
      let(:cassette) { 'gemini/language/complete_default_prompt' }

      subject { instance.complete('Hello') }

      it 'returns completions' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.provider).to eq(:gemini)
          expect(subject.model).to eq('gemini-pro')

          expect(subject.value).to eq('Hi there! How can I assist you today?')
          expect(subject.values).to eq(['Hi there! How can I assist you today?'])

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end
    end
  end
end
