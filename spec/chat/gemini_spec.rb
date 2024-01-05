# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Chat do
  describe 'Gemini' do
    let(:provider) { :gemini }
    let(:cassette) { 'gemini/language/chat_default_message' }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    let(:instance) { described_class.new(provider, token) }
    let(:prompt) { 'What is the capital of Turkey?' }

    subject { instance.message(prompt) }

    context 'client options' do
      let(:client) { instance_double(GenAI::Api::Client) }

      before do
        allow(GenAI::Api::Client).to receive(:new).and_return(client)
        allow(client).to receive(:post).and_return({ 'candidates' => [] })
      end

      context 'with single message' do
        it 'calls API with single message' do
          subject

          expect(client).to have_received(:post).with(
            '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
            {
              contents: [{parts: [{text: 'What is the capital of Turkey?'}], role: 'user'}],
              generationConfig: {}
            }
          )
        end
      end

      context 'with context message' do
        it 'calls API with single message' do
          instance.start(context: 'Respond as if current year is 1800')

          subject

          expect(client).to have_received(:post).with(
            '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
            {
              contents: [{parts: [{text: "Respond as if current year is 1800\nWhat is the capital of Turkey?"}], role: 'user'}],
              generationConfig: {}
            }
          )
        end
      end

      context 'with message history' do
        let(:prompt) { 'What about France?' }
        let(:messages) do
          [
            { role: 'user', parts: [{text: 'What is the capital of Turkey?' }]},
            { role: 'model', parts: [{text: 'The capital of Turkey is Ankara.' }]},
            { role: 'user', parts: [{text: 'What about France?' }]}
          ]
        end

        context 'with symbolized keys' do
          let(:history) do
            [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'The capital of Turkey is Ankara.' }
            ]
          end

          it 'calls API with full message history' do
            instance.start(history: history)

            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              { contents: messages, generationConfig: {} }
            )
          end
        end

        context 'with stringified keys' do
          let(:history) do
            [
              { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
              { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' }
            ]
          end

          it 'calls API with full message history' do
            instance.start(history: history)

            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              { contents: messages, generationConfig: {} }
            )
          end
        end
      end

      context 'with examples' do
        let(:prompt) { 'What is the capital of Thailand?' }

        context 'with single example' do
          let(:examples) do
            [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'Ankara' },
              { role: 'user', content: 'What is the capital of France?' },
              { role: 'assistant', content: 'Paris' }
            ]
          end

          it 'calls API with history including examples' do
            instance.start(examples: examples)

            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              {
                contents: [
                  { role: 'user', parts: [{text: "user: What is the capital of Turkey?\nassistant: Ankara\nuser: What is the capital of France?\nassistant: Paris\nWhat is the capital of Thailand?" }]}
                ],
                generationConfig: {}
              }
            )
          end
        end

        context 'with string keys' do
          let(:examples) do
            [
              { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
              { 'role' => 'assistant', 'content' => 'Ankara' },
              { 'role' => 'user', 'content' => 'What is the capital of France?' },
              { 'role' => 'assistant', 'content' => 'Paris' }
            ]
          end

          it 'calls API with history including examples' do
            instance.start(examples: examples)

            subject

            expect(client).to have_received(:post).with(
              '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN',
              {
                contents: [
                  { role: 'user', parts: [{text: "user: What is the capital of Turkey?\nassistant: Ankara\nuser: What is the capital of France?\nassistant: Paris\nWhat is the capital of Thailand?" }]}
                ],
                generationConfig: {}
              }
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

            expect(subject.provider).to eq(:gemini)
            expect(subject.model).to eq('gemini-pro')

            expect(subject.value).to eq('Ankara')
            expect(subject.values).to eq(['Ankara'])

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with context' do
        let(:cassette) { 'gemini/chat/chat_message_with_context' }

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

      context 'with message history' do
        let(:cassette) { 'gemini/chat/chat_message_with_history' }

        before do
          instance.start(history: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'The capital of Turkey is Ankara.' }
          ])
        end

        subject { instance.message('What about France?') }

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
        let(:cassette) { 'gemini/chat/chat_message_with_examples' }

        before do
          instance.start(examples: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'Ankara' },
            { role: 'user', content: 'What is the capital of France?' },
            { role: 'assistant', content: 'Paris' }
          ])
        end

        subject { instance.message('What is the capital of Thailand?') }

        it 'responds similarly to examples' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to eq('Bangkok')

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'gemini/chat/chat_message_with_options' }

        subject do
          instance.message('Hi, how are you?', temperature: 0.9, max_output_tokens: 13)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.values).to eq(["As an AI language model, I don't have personal feelings"])

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end

      context 'with every possible parameter' do
        let(:client) { double('GenAI::Api::Client') }

        subject do
          instance.message('Hi, how are you?', temperature: 0.9, max_output_tokens: 13)
        end

        before do
          allow(GenAI::Api::Client).to receive(:new).and_return(client)
          allow(client).to receive(:post).and_return({ 'candidates' => [] })

          instance.start(
            context: 'You are a chatbot',
            examples: [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'Ankara' }
            ],
            history: [
              { role: 'user', content: 'What is the capital of France?' },
              { role: 'assistant', content: 'Paris' }
            ]
          )
        end

        it 'calls OpenAI::Client#chat with passed options' do
          subject

          expect(client).to have_received(:post).with(
            '/v1beta/models/gemini-pro:generateContent?key=FAKE_TOKEN', {
            contents: [
              { role: 'user', parts: [{ text: "You are a chatbot\nuser: What is the capital of Turkey?\nassistant: Ankara\nWhat is the capital of France?"}]},
              { role: 'model', parts: [{ text: 'Paris' }]},
              { role: 'user', parts: [{text: 'Hi, how are you?'}]}
            ],
            generationConfig: {
              temperature: 0.9,
              max_output_tokens: 13
            }
          }
          )
        end
      end

      context 'with unsupported provider' do
        let(:provider) { :monster_ai }

        it 'raises an GenAI::UnsupportedProvider error' do
          expect { subject }.to raise_error(GenAI::UnsupportedProvider, /Unsupported Chat provider 'monster_ai'/)
        end
      end
    end
  end
end
