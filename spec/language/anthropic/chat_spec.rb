# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'Anthropic' do
    describe '#chat' do
      let(:provider) { :anthropic }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:cassette) { 'anthropic/language/chat_default_message' }
      let(:instance) { described_class.new(provider, token) }
      let(:messages) { [{ role: 'user', content: prompt }] }
      let(:prompt) { 'What is the capital of Turkey?' }

      subject { instance.chat(messages) }

      context 'client options' do
        let(:client) { instance_double(GenAI::Api::Client) }

        before do
          allow(GenAI::Api::Client).to receive(:new).and_return(client)
          allow(client).to receive(:post).and_return({ 'content' => {} })
        end

        context 'with default options' do
          it 'calls API with default parameters' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/messages',
              {
                messages:,
                max_tokens: 1024,
                model: 'claude-2.1'
              }
            )
          end
        end

        context 'with custom options' do
          let(:options) do
            {
              model: 'claude-instant-2.1',
              max_tokens: 2048,
              system: 'You are a chatbot.',
              temperature: 0.5,
              top_k: 0.6,
              top_p: 0.7
            }
          end

          subject { instance.chat(messages, options) }

          it 'calls API with passed parameters' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/messages',
              {
                messages:,
                max_tokens: 2048,
                model: 'claude-instant-2.1',
                system: 'You are a chatbot.',
                temperature: 0.5,
                top_k: 0.6,
                top_p: 0.7
              }
            )
          end
        end

        context 'with stringified keys' do
          subject { instance.chat([{'role' => 'user', 'content' => prompt}]) }

          it 'calls API with correct contents' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/messages',
              {
                messages: [{ role: 'user', content: prompt }],
                max_tokens: 1024,
                model: 'claude-2.1'
              }
            )
          end
        end
      end

      context 'api response' do
        it 'returns GenAI::Result with response' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.provider).to eq(:anthropic)
            expect(subject.model).to eq('claude-2.1')

            expect(subject.value).to eq('The capital of Turkey is Ankara.')
            expect(subject.values).to match(['The capital of Turkey is Ankara.'])

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end
    end
  end
end
