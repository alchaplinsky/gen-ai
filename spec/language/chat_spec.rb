# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Language do
  describe '#chat' do
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    subject { instance.chat('What is the capital of Turkey?') }

    context 'with OpenAI provider' do
      let(:provider) { :openai }
      let(:cassette) { 'openai/chat/default_message' }

      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first).to eq({ 'content' => 'The capital of Turkey is Ankara.', 'role' => 'assistant' })
        end
      end

      context 'with context' do
        let(:cassette) { 'openai/chat/message_with_context' }

        subject { instance.chat('What is the capital of Turkey?', context: 'Respond as if current year is 1800') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to eq({ 'content' => 'The capital of Turkey is Constantinople.', 'role' => 'assistant' })
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'openai/chat/message_with_history' }

        subject do
          instance.chat('What about France?', history: [
                          { 'role' => 'user', 'content' => 'What is the capital of Turkey?' },
                          { 'role' => 'assistant', 'content' => 'The capital of Turkey is Ankara.' }
                        ])
        end

        it 'responds according to message history' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to eq({ 'content' => 'The capital of France is Paris.', 'role' => 'assistant' })
          end
        end
      end

      context 'with examples' do
        let(:cassette) { 'openai/chat/message_with_examples' }

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
            expect(subject).to be_a(Array)
            expect(subject.first).to eq({ 'content' => 'Bangkok', 'role' => 'assistant' })
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'openai/chat/message_with_options' }

        subject do
          instance.chat('Hi, how are you?', model: 'gpt-3.5-turbo-0301', temperature: 0.9, max_tokens: 13, n: 2)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to eq({ 'content' => 'Hello! As an AI language model, I do not have feelings', 'role' => 'assistant' })
            expect(subject.last).to eq({ 'content' => "Hello! I'm just a computer program, so I don't", 'role' => 'assistant' })
          end
        end
      end
    end

    context 'with Google PaLM2 provider' do
      let(:provider) { :google_palm }
      let(:cassette) { 'google/chat/default_message' }

      it 'returns chat response' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first['author']).to eq('1')
          expect(subject.first['content']).to match('The capital of Turkey is Ankara.')
        end
      end

      context 'with context' do
        let(:cassette) { 'google/chat/message_with_context' }

        subject { instance.chat('What is the capital of Turkey?', context: 'Respond as if current year was 1800') }

        it 'responds according to context' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first['author']).to eq('1')
            expect(subject.first['content']).to match('The capital of Turkey in 1800 was Constantinople. It was renamed Istanbul in 1930.')
          end
        end
      end

      context 'with message history' do
        let(:cassette) { 'google/chat/message_with_history' }

        subject do
          instance.chat('What about France?', history: [
                          { 'author' => '0', 'content' => 'What is the capital of Turkey?' },
                          { 'author' => '1', 'content' => 'The capital of Turkey is Ankara.' }
                        ])
        end

        it 'responds according to message history' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to eq({ 'content' => 'The capital of France is Paris.', 'author' => '1' })
          end
        end
      end

      context 'with examples' do
        let(:cassette) { 'google/chat/message_with_examples' }

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
            expect(subject).to be_a(Array)
            expect(subject.first['author']).to eq('1')
            expect(subject.first['content']).to match('Bangkok')
          end
        end
      end

      context 'with custom options' do
        let(:cassette) { 'google/chat/message_with_options' }

        subject do
          instance.chat('Hi, how are you?', temperature: 0.9, candidate_count: 2)
        end

        it 'responds with completions according to passed options' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first['author']).to eq('1')
            expect(subject.first['content']).to eq('I am doing well, thank you for asking! How are you today?')
            expect(subject.last['author']).to eq('1')
            expect(subject.last['content']).to eq('I am doing well, thank you for asking! I am excited to be able to help people with their tasks and to learn more about the world. How are you doing today?')
          end
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
