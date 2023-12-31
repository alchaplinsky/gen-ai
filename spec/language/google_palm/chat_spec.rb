# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'PaLM' do
    describe '#chat' do
      let(:provider) { :google_palm }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }
      let(:cassette) { 'google_palm/language/chat_default_message' }

      subject { instance.chat('What is the capital of Turkey?') }

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
        let(:cassette) { 'google_palm/language/chat_message_with_context' }

        subject { instance.chat('What is the capital of Turkey?', context: 'Respond as if current year was 1800') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)
            expect(subject.value).to match('The capital of Turkey in 1800 was Constantinople. It was renamed Istanbul in 1930.')
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'google_palm/language/chat_message_with_history' }

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
        let(:cassette) { 'google_palm/language/chat_message_with_examples' }

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
        let(:cassette) { 'google_palm/language/chat_message_with_options' }

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
  end
end
