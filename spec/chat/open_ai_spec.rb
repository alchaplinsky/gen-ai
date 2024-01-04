# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Chat do
  describe 'OpenAI' do
    let(:provider) { :open_ai }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
    let(:instance) { described_class.new(provider, token) }
    let(:cassette) { 'openai/language/chat_default_message' }
    let(:prompt) { 'What is the capital of Turkey?' }

    subject { instance.message(prompt) }

    context 'client options' do
      let(:client) { instance_double(OpenAI::Client) }

      before do
        allow(OpenAI::Client).to receive(:new).and_return(client)
        allow(client).to receive(:chat).and_return({ 'choices' => [] })
      end

      context 'with single message' do
        it 'calls API with single message' do
          subject

          expect(client).to have_received(:chat).with({
            parameters: {
              messages: [{role: 'user', content: 'What is the capital of Turkey?'}],
              model: 'gpt-3.5-turbo-1106'
            }
          })
        end
      end

      context 'with context message' do
        it 'calls API with single message' do
          instance.start(context: 'Respond as if current year is 1800')

          subject

          expect(client).to have_received(:chat).with(
            {
              parameters: {
                messages: [
                  {role: 'system', content: 'Respond as if current year is 1800'},
                  { role: 'user', content: 'What is the capital of Turkey?'}
                ],
                model: 'gpt-3.5-turbo-1106'
              }
            }
          )
        end
      end

      context 'with message history' do
        let(:prompt) { 'What about France?' }

        it 'calls API with full message history' do
          instance.start(history: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'The capital of Turkey is Ankara.' }
          ])

          subject

          expect(client).to have_received(:chat).with({
            parameters: {
              messages: [
                { role: 'user', content: 'What is the capital of Turkey?' },
                { role: 'assistant', content: 'The capital of Turkey is Ankara.' },
                { role: 'user', content: 'What about France?' }
              ],
              model: 'gpt-3.5-turbo-1106'
            }
          })
        end
      end

      context 'with examples' do
        let(:prompt) { 'What is the capital of Thailand?' }

        it 'calls API with history including examples' do
          instance.start(examples: [
            { role: 'user', content: 'What is the capital of Turkey?' },
            { role: 'assistant', content: 'Ankara' },
            { role: 'user', content: 'What is the capital of France?' },
            { role: 'assistant', content: 'Paris' }
          ])

          subject

          expect(client).to have_received(:chat).with(
            parameters: {
               messages: [
                 { role: 'user', content: 'What is the capital of Turkey?' },
                 { role: 'assistant', content: 'Ankara' },
                 { role: 'user', content: 'What is the capital of France?' },
                 { role: 'assistant', content: 'Paris' },
                 { role: 'user', content: 'What is the capital of Thailand?' }
               ],
               model: 'gpt-3.5-turbo-1106'
             }
          )
        end
      end
    end

    context 'api response' do
      context 'with single message' do
        it 'returns chat response' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.provider).to eq(:open_ai)
            expect(subject.model).to eq('gpt-3.5-turbo-1106')

            expect(subject.value).to eq('The capital of Turkey is Ankara.')
            expect(subject.values).to eq(['The capital of Turkey is Ankara.'])

            expect(subject.prompt_tokens).to eq(14)
            expect(subject.completion_tokens).to eq(7)
            expect(subject.total_tokens).to eq(21)
          end
        end
      end

      context 'with context' do
        let(:cassette) { 'openai/chat/chat_message_with_context' }

        before do
          instance.start(context: 'Respond as if current year is 1800')
        end

        subject { instance.message('What is the capital of Turkey?') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.value).to eq('The capital of Turkey is Constantinople.')

            expect(subject.prompt_tokens).to eq(27)
            expect(subject.completion_tokens).to eq(8)
            expect(subject.total_tokens).to eq(35)
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'openai/chat/chat_message_with_history' }

        before do
          instance.start(history: [
            { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
            { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' }
          ])
        end

        subject { instance.message('What about France?') }

        it 'responds according to message history' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.value).to eq('The capital of France is Paris.')

            expect(subject.prompt_tokens).to eq(33)
            expect(subject.completion_tokens).to eq(7)
            expect(subject.total_tokens).to eq(40)
          end
        end
      end

      context 'with examples' do
        let(:cassette) { 'openai/chat/chat_message_with_examples' }

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

            expect(subject.prompt_tokens).to eq(48)
            expect(subject.completion_tokens).to eq(2)
            expect(subject.total_tokens).to eq(50)
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'openai/chat/chat_message_with_options' }

        subject do
          instance.message('Hi, how are you?', model: 'gpt-3.5-turbo-0301', temperature: 0.9, max_tokens: 13, n: 2)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.values).to eq([
              'Hello! As an AI language model, I do not have feelings',
              "Hello! I'm just a computer program, so I don't"
            ])

            expect(subject.prompt_tokens).to eq(19)
            expect(subject.completion_tokens).to eq(26)
            expect(subject.total_tokens).to eq(45)
          end
        end
      end

      context 'with every possible parameter' do
        let(:client) { double('OpenAI::Client') }

        subject do
          instance.message('Hi, how are you?', model: 'gpt-3.5-turbo-0301', temperature: 0.9, max_tokens: 13, n: 2)
        end

        before do
          allow(OpenAI::Client).to receive(:new).and_return(client)
          allow(client).to receive(:chat).and_return({ 'choices' => [] })

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

          expect(client).to have_received(:chat).with(parameters: {
            messages: [
              { content: 'You are a chatbot', role: 'system' },
              { content: 'What is the capital of Turkey?', role: 'user' },
              { content: 'Ankara', role: 'assistant' },
              { content: 'What is the capital of France?', role: 'user' },
              { content: 'Paris', role: 'assistant' },
              { content: 'Hi, how are you?', role: 'user' }
            ],
            model: 'gpt-3.5-turbo-0301',
            temperature: 0.9,
            max_tokens: 13,
            n: 2
          })
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
