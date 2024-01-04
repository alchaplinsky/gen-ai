# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'OpenAI' do
    describe '#embed' do
      let(:provider) { :open_ai }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }

      subject { instance.embed(input) }

      context 'with single string input' do
        let(:input) { 'Hello' }
        let(:cassette) { 'openai/language/embed_single_input' }

        it 'returns an array with one embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.provider).to eq(:open_ai)
            expect(subject.model).to eq('text-embedding-ada-002')

            expect(subject.value).to be_a(Array)
            expect(subject.value.size).to eq(1536)
            expect(subject.value).to all(be_a(Float))

            expect(subject.values).to be_a(Array)
            expect(subject.values.size).to eq(1)

            expect(subject.prompt_tokens).to eq(1)
            expect(subject.completion_tokens).to eq(0)
            expect(subject.total_tokens).to eq(1)
          end
        end

        context 'with custom model' do
          let(:input) { 'Hello' }
          let(:model) { 'text-similarity-davinci-001' }
          let(:cassette) { "openai/language/embed_single_input_#{model}" }

          subject { instance.embed(input, model: model) }

          it 'returns an array with one embeddings' do
            VCR.use_cassette(cassette) do
              expect(subject).to be_a(GenAI::Result)

              expect(subject.model).to eq('text-similarity-davinci-001')

              expect(subject.value.size).to eq(12_288)
              expect(subject.value).to all(be_a(Float))
            end
          end
        end
      end

      context 'with array input' do
        let(:input) { %w[Hello Cześć] }
        let(:cassette) { 'openai/language/embed_multiple_inputs' }

        it 'returns an array with two embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.values[0]).to all(be_a(Float))
            expect(subject.values[0].size).to eq(1536)

            expect(subject.values[1]).to all(be_a(Float))
            expect(subject.values[1].size).to eq(1536)
          end
        end
      end

      context 'invalid input' do
        let(:input) { nil }
        let(:cassette) { 'openai/language/embed_invalid_input' }

        it 'raises an API error' do
          VCR.use_cassette(cassette) do
            expect { subject }.to raise_error(GenAI::ApiError, /Please submit an `input`/)
          end
        end
      end

      context 'with unsupported provider' do
        let(:input) { 'Hello' }
        let(:provider) { :monster_ai }

        it 'raises an GenAI::UnsupportedProvider error' do
          expect { subject }.to raise_error(GenAI::UnsupportedProvider, /Unsupported LLM provider 'monster_ai'/)
        end
      end
    end
  end
end
