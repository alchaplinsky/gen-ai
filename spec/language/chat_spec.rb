# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#chat' do
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    subject { instance.chat('What is the capital of Turkey?') }

    context 'with OpenAI provider' do
      let(:provider) { :open_ai }
      let(:cassette) { 'openai/language/chat_default_message' }

      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.provider).to eq(:open_ai)
          expect(subject.model).to eq('gpt-3.5-turbo')

          expect(subject.value).to eq('The capital of Turkey is Ankara.')
          expect(subject.values).to eq(['The capital of Turkey is Ankara.'])

          expect(subject.prompt_tokens).to eq(14)
          expect(subject.completion_tokens).to eq(7)
          expect(subject.total_tokens).to eq(21)
        end
      end

      context 'with context' do
        let(:cassette) { 'openai/language/chat_message_with_context' }

        subject { instance.chat('What is the capital of Turkey?', context: 'Respond as if current year is 1800') }

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
        let(:cassette) { 'openai/language/chat_message_with_history' }

        subject do
          instance.chat('What about France?', history: [
            { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
            { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' }
          ])
        end

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
        let(:cassette) { 'openai/language/chat_message_with_examples' }

        subject do
          instance.chat('What is the capital of Thailand?', examples: [
            { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
            { 'role' => 'assistant', 'content' => 'Ankara' },
            { 'role' => 'user', 'content' => 'What is the capital of France?' },
            { 'role' => 'assistant', 'content' => 'Paris' }
          ])
        end

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
        let(:cassette) { 'openai/language/chat_message_with_options' }

        subject do
          instance.chat('Hi, how are you?', model: 'gpt-3.5-turbo-0301', temperature: 0.9, max_tokens: 13, n: 2)
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
          instance.chat('Hi, how are you?',
            context: 'You are a chatbot',
            examples: [
              { role: 'user', content: 'What is the capital of Turkey?' },
              { role: 'assistant', content: 'Ankara' }
            ],
            history: [
              { role: 'user', content: 'What is the capital of France?' },
              { role: 'assistant', content: 'Paris' }
            ],
            model: 'gpt-3.5-turbo-0301',
            temperature: 0.9,
            max_tokens: 13,
            n: 2)
        end

        before do
          allow(OpenAI::Client).to receive(:new).and_return(client)
          allow(client).to receive(:chat).and_return({ 'choices' => [] })
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
    end

    context 'with Google PaLM2 provider' do
      let(:provider) { :google_palm }
      let(:cassette) { 'google/language/chat_default_message' }

      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)

          expect(subject.provider).to eq(:google_palm)
          expect(subject.model).to eq('chat-bison-001')

          expect(subject.value).to match('The capital of Turkey is Ankara.')
          expect(subject.values).to match([a_string_matching('The capital of Turkey is Ankara.')])

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end

      context 'with context' do
        let(:cassette) { 'google/language/chat_message_with_context' }

        subject { instance.chat('What is the capital of Turkey?', context: 'Respond as if current year was 1800') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to match('The capital of Turkey in 1800 was Constantinople. It was renamed Istanbul in 1930.')
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'google/language/chat_message_with_history' }

        subject do
          instance.chat('What about France?', history: [
            { 'author' => '0', 'content' => 'What is the capital of Turkey?' },
            { 'author' => '1', 'content' => 'The capital of Turkey is Ankara.' }
          ])
        end

        it 'responds according to message history' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to eq('The capital of France is Paris.')
          end
        end
      end

      context 'with examples' do
        let(:cassette) { 'google/language/chat_message_with_examples' }

        subject do
          instance.chat('What is the capital of Thailand?', examples: [
            { 'author' => '0', 'content' => 'What is the capital of Turkey?' },
            { 'author' => '1', 'content' => 'Ankara' },
            { 'author' => '0', 'content' => 'What is the capital of France?' },
            { 'author' => '1', 'content' => 'Paris' }
          ])
        end

        it 'responds similarly to examples' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to match('Bangkok')
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'google/language/chat_message_with_options' }

        subject do
          instance.chat('Hi, how are you?', temperature: 0.9, candidate_count: 2)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.values[0]).to eq('I am doing well, thank you for asking! How are you today?')
            expect(subject.values[1]).to eq('I am doing well, thank you for asking! I am excited to be able to help people with their tasks and to learn more about the world. How are you doing today?')
          end
        end
      end

      context 'with every possible parameter' do
        let(:client) { double('GooglePalmApi::Client') }

        subject do
          instance.chat('Hi, how are you?',
            context: 'You are a chatbot',
            examples: [
              { author: '0', content: 'What is the capital of Turkey?' },
              { author: '1', content: 'Ankara' },
              { author: '0', content: 'What is the capital of France?' },
              { author: '1', content: 'Paris' }
            ],
            history: [
              { author: '0', content: 'What is the capital of Germany?' },
              { author: '1', content: 'Berlin' }
            ],
            model: 'text-bison-002',
            temperature: 0.9,
            max_output_tokens: 13,
            candidate_count: 2)
        end

        before do
          allow(GooglePalmApi::Client).to receive(:new).and_return(client)
          allow(client).to receive(:generate_chat_message).and_return({ 'candidates' => [] })
        end

        it 'calls GooglePalmApi::Client#chat with passed options' do
          subject
          expect(client).to have_received(:generate_chat_message).with({
            context: 'You are a chatbot',
            examples: [
              { input: { content: 'What is the capital of Turkey?' }, output: { content: 'Ankara' } },
              { input: { content: 'What is the capital of France?' }, output: { content: 'Paris' } }
            ],
            messages: [
              { author: '0', content: 'What is the capital of Germany?' },
              { author: '1', content: 'Berlin' },
              { author: '0', content: 'Hi, how are you?' }
            ],
            model: 'text-bison-002',
            temperature: 0.9,
            max_output_tokens: 13,
            candidate_count: 2
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
