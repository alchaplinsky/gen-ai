# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Chat do
  describe 'Antropic' do
    let(:provider) { :anthropic }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
    let(:instance) { described_class.new(provider, token) }
    let(:cassette) { 'anthropic/language/chat_default_message' }

    subject { instance.message('What is the capital of Turkey?') }

    context 'with single message' do
      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.provider).to eq(:anthropic)
          expect(subject.model).to eq('claude-2.1')

          expect(subject.value).to eq('The capital of Turkey is Ankara.')
          expect(subject.values).to eq(['The capital of Turkey is Ankara.'])

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end
    end

    context 'with context' do
      let(:cassette) { 'anthropic/chat/chat_message_with_context' }

      before do
        instance.start(context: 'Respond as if current year is 1800')
      end

      subject { instance.message('What is the capital of Turkey?') }

      it 'responds according to context' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.value).to eq('Turkey was not yet a country at that time, and therefore did not have a capital city.')

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end
    end
  end
end
