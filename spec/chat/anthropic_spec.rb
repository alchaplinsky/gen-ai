# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Chat do
  describe 'Antropic' do
    let(:provider) { :anthropic }
    let(:cassette) { 'anthropic/language/chat_default_message' }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    let(:chat) { described_class.new(provider, token) }
    let(:prompt) { 'What is the capital of Turkey?' }

    subject { chat.message(prompt) }

    context 'client options' do
      let(:client) { instance_double(GenAI::Api::Client) }

      before do
        allow(GenAI::Api::Client).to receive(:new).and_return(client)
        allow(client).to receive(:post).and_return({ 'content' => {} })
      end

      context 'with single message' do
        it 'calls API with single message' do
          subject

          expect(client).to have_received(:post).with(
            '/v1/messages',
            {
              messages: [{ role: 'user', content: 'What is the capital of Turkey?' }],
              max_tokens: 1024,
              model: 'claude-2.1'
            }
          )
        end
      end

      context 'with context message' do
        it 'calls API with single message' do
          chat.start(context: 'Respond as if current year is 1800')

          subject

          expect(client).to have_received(:post).with(
            '/v1/messages',
            {
              messages: [{ role: 'user', content: 'What is the capital of Turkey?' }],
              system: 'Respond as if current year is 1800',
              max_tokens: 1024,
              model: 'claude-2.1'
            }
          )
        end
      end

      context 'with message history' do
        let(:prompt) { 'What about France?' }
        let(:messages) do
          [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'The capital of Turkey is Ankara.' },
            { role: 'user', content: 'What about France?' }
          ]
        end

        context 'symbolized keys' do
          let(:history) do
            [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'The capital of Turkey is Ankara.' }
            ]
          end

          it 'calls API with full message history' do
            chat.start(history: history)

            subject

            expect(client).to have_received(:post).with(
              '/v1/messages', { messages: messages, max_tokens: 1024, model: 'claude-2.1' }
            )
          end
        end

        context 'string keys' do
          let(:history) do
            [
              { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
              { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' }
            ]
          end

          it 'calls API with full message history' do
            chat.start(history: history)

            subject

            expect(client).to have_received(:post).with(
              '/v1/messages', { messages: messages, max_tokens: 1024, model: 'claude-2.1' }
            )
          end
        end
      end

      context 'with examples' do
        let(:prompt) { 'What is the capital of Thailand?' }
        let(:messages) do
          [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'Ankara' },
            { role: 'user', content: 'What is the capital of France?' },
            { role: 'assistant', content: 'Paris' },
            { role: 'user', content: 'What is the capital of Thailand?' }
          ]
        end

        context 'symbolized keys' do
          let(:examples) do
            [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'Ankara' },
              { role: 'user', content: 'What is the capital of France?' },
              { role: 'assistant', content: 'Paris' }
            ]
          end

          it 'calls API with history including examples' do
            chat.start(examples: examples)

            subject

            expect(client).to have_received(:post).with(
              '/v1/messages', { messages: messages, max_tokens: 1024, model: 'claude-2.1' }
            )
          end
        end

        context 'string keys' do
          let(:examples) do
            [
              { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
              { 'role' => 'assistant', 'content' => 'Ankara' },
              { 'role' => 'user', 'content' => 'What is the capital of France?' },
              { 'role' => 'assistant', 'content' => 'Paris' }
            ]
          end

          it 'calls API with history including examples' do
            chat.start(examples: examples)

            subject

            expect(client).to have_received(:post).with(
              '/v1/messages', { messages: messages, max_tokens: 1024, model: 'claude-2.1' }
            )
          end
        end
      end
    end

    context 'api response' do
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
          chat.start(context: 'Respond as if current year is 1800')
        end

        subject { chat.message('What is the capital of Turkey?') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.value).to match('The capital of the Ottoman Empire in 1800 was Constantinople, known today as Istanbul')

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'anthropic/chat/chat_message_with_history' }

        before do
          chat.start(history: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'The capital of Turkey is Ankara.' }
          ])
        end

        subject { chat.message('What about France?') }

        it 'responds according to message history' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.value).to eq('The capital of France is Paris.')

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with examples' do
        let(:cassette) { 'anthropic/chat/chat_message_with_examples' }

        before do
          chat.start(examples: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'Ankara' },
            { role: 'user', content: 'What is the capital of France?' },
            { role: 'assistant', content: 'Paris' }
          ])
        end

        subject { chat.message('What is the capital of Thailand?') }

        it 'responds similarly to examples' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to eq('Bangkok is the capital and largest city of Thailand.')

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'anthropic/chat/chat_message_with_options' }

        subject do
          chat.message('Hi, how are you?', temperature: 0.9, max_tokens: 4)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.values).to eq(["I'm doing well"])

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end
    end
  end
end
