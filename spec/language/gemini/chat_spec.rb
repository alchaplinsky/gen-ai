# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'Gemini' do
    describe '#chat' do
      let(:provider) { :gemini }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }
      let(:cassette) { 'gemini/language/chat_default_message' }
      let(:messages) { [{ role: 'user', content: prompt }] }
      let(:prompt) { 'What is the capital of Turkey?' }

      subject { instance.chat(messages) }

      context 'client options' do
        let(:client) { instance_double(GenAI::Api::Client) }

        before do
          allow(GenAI::Api::Client).to receive(:new).and_return(client)
          allow(client).to receive(:post).and_return({ 'candidates' => [] })
        end

        context 'with default options' do
          it 'calls API with default parameters' do
            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              {
                contents: [{ role: 'user', parts: [{text: prompt }]}],
                generationConfig: {}
              }
            )
          end
        end

        context 'with custom options' do
          let(:options) do
            {
              max_output_tokens: 2048,
              temperature: 0.5,
              top_k: 0.6,
              top_p: 0.7
            }
          end

          subject { instance.chat(messages, options) }

          it 'calls API with passed parameters' do
            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              {
                contents: [{ role: 'user', parts: [{text: prompt }]}],
                generationConfig: {
                  max_output_tokens: 2048,
                  temperature: 0.5,
                  top_k: 0.6,
                  top_p: 0.7
                }
              }
            )
          end
        end

        context 'with stringified keys' do
          subject { instance.chat([{'role' => 'user', 'content' => prompt}]) }

          it 'calls API with correct contents' do
            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              {
                contents: [{ role: 'user', parts: [{text: prompt }]}],
                generationConfig: {}
              }
            )
          end
        end
      end

      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.provider).to eq(:gemini)
          expect(subject.model).to eq('gemini-pro')

          expect(subject.value).to match('Ankara')
          expect(subject.values).to match([a_string_matching('Ankara')])

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end

      context 'with context' do
        let(:cassette) { 'gemini/language/chat_message_with_context' }
        let(:prompt) { "Current year is 1800\nWhat is the capital of Turkey?" }

        subject { instance.chat(messages) }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to match('There was no country called Turkey in 1800.')
          end
        end
      end

      context 'with custom options' do
        let(:prompt) { 'Hi, can you help me?' }
        let(:cassette) { 'gemini/language/chat_message_with_options' }

        subject do
          instance.chat(messages, { temperature: 0, max_output_tokens: 14 })
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.values).to eq(['Sure, I can help you with a variety of tasks and questions.'])
          end
        end
      end
    end
  end
end
