# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'OpenAI' do
    describe '#chat' do
      let(:provider) { :open_ai }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }
      let(:cassette) { 'openai/language/chat_default_message' }
      let(:messages) { [{ role: 'user', content: prompt }] }
      let(:prompt) { 'What is the capital of Turkey?' }

      subject { instance.chat(messages) }

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

      context 'with context' do
        let(:cassette) { 'openai/language/chat_message_with_context' }
        let(:messages) do
          [
            { role: 'system', content: 'Respond as if current year is 1800' },
            { role: 'user', content: 'What is the capital of Turkey?' }
          ]
        end

        subject { instance.chat(messages) }

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
        let(:messages) do
          [
            { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
            { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' },
            { 'role' => 'user', 'content' => 'What about France?'}
          ]
        end

        subject do
          instance.chat(messages)
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
        let(:messages) do
          [
            { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
            { 'role' => 'assistant', 'content' => 'Ankara' },
            { 'role' => 'user', 'content' => 'What is the capital of France?' },
            { 'role' => 'assistant', 'content' => 'Paris' },
            { 'role' => 'user', 'content' => 'What is the capital of Thailand?'}
          ]
        end

        subject do
          instance.chat(messages)
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
        let(:prompt) { 'Hi, how are you?' }

        subject do
          instance.chat(messages, model: 'gpt-3.5-turbo-0301', temperature: 0.9, max_tokens: 13, n: 2)
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
          instance.chat([
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

      context 'with unsupported provider' do
        let(:provider) { :monster_ai }

        it 'raises an GenAI::UnsupportedProvider error' do
          expect { subject }.to raise_error(GenAI::UnsupportedProvider, /Unsupported LLM provider 'monster_ai'/)
        end
      end

      context 'with streaming response' do
        let(:cassette) { 'openai/language/chat_message_streaming' }
        let(:block) { proc { |chunk| chunk } }

        before do
          allow(block).to receive(:call).and_call_original
        end

        subject do
          instance.chat(messages, {}, &block)
        end

        it 'yields each chunk to the block' do
          VCR.use_cassette(cassette) do
            subject
            expect(block).to have_received(:call).exactly(7).times
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: 'The')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: ' capital')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: ' of')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: ' Turkey')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: ' is')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: ' Ankara')))
            expect(block).to have_received(:call).with(an_instance_of(GenAI::Chunk).and(having_attributes(value: '.')))
          end
        end

        it 'returns full response at the end' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.provider).to eq(:open_ai)
            expect(subject.model).to eq('gpt-3.5-turbo-1106')

            expect(subject.value).to eq('The capital of Turkey is Ankara.')
            expect(subject.values).to eq(['The capital of Turkey is Ankara.'])

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(7)
            expect(subject.total_tokens).to eq(nil)
          end
        end
      end
    end
  end
end
