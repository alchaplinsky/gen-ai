# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#complete' do
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    subject { instance.complete('Hello') }

    context 'with openai provider' do
      let(:provider) { :openai }
      let(:cassette) { 'openai/complete/default_prompt' }

      it 'returns completions' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first).to eq({
            'content' => 'Hi there! How can I assist you today?',
            'role' => 'assistant'
          })
        end
      end

      context 'with options' do
        let(:client) { double('OpenAI::Client') }

        before do
          allow(OpenAI::Client).to receive(:new).and_return(client)
          allow(client).to receive(:chat).and_return({ 'choices' => [] })
        end

        context 'with default options' do
          subject { instance.complete('Hello') }

          it 'passes options to the client' do
            subject
            expect(client).to have_received(:chat).with({
              parameters: {
                messages: [{ role: 'user', content: 'Hello' }],
                model: 'gpt-3.5-turbo'
              }
            })
          end
        end

        context 'with custom options' do
          subject { instance.complete('Hello', model: 'gpt-4', temperature: 0.9, n: 2) }

          it 'passes options to the client' do
            subject
            expect(client).to have_received(:chat).with(parameters: {
              messages: [{ role: 'user', content: 'Hello' }],
              model: 'gpt-4',
              temperature: 0.9,
              n: 2
            })
          end
        end
      end
    end

    context 'with google_palm provider' do
      let(:provider) { :google_palm }
      let(:cassette) { 'google/complete/default_prompt' }

      it 'returns completions' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(Array)
          expect(subject.first['output']).to eq(', world!')
        end
      end

      context 'with options' do
        let(:client) { double('GooglePalmApi::Client') }

        before do
          allow(GooglePalmApi::Client).to receive(:new).and_return(client)
          allow(client).to receive(:generate_text).and_return({ 'choices' => [] })
        end

        context 'with default options' do
          subject { instance.complete('Hello') }

          it 'passes options to the client' do
            subject
            expect(client).to have_received(:generate_text).with({
              prompt: 'Hello',
              model: 'text-bison-001'
            })
          end
        end

        context 'with custom options' do
          subject { instance.complete('Hello', model: 'text-bison-002', temperature: 0.9, candidate_count: 2) }

          it 'passes options to the client' do
            subject
            expect(client).to have_received(:generate_text).with({
              prompt: 'Hello',
              model: 'text-bison-002',
              temperature: 0.9,
              candidate_count: 2
            })
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
