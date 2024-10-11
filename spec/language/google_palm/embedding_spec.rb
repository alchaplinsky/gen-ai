# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe 'PaLM' do
    describe '#embed' do
      let(:provider) { :google_palm }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
      let(:instance) { described_class.new(provider, token) }

      subject { instance.embed(input) }

      context 'with singe string input' do
        let(:input) { 'Hello' }
        let(:cassette) { 'google_palm/language/embed_single_input' }

        it 'returns an array with one embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.provider).to eq(:google_palm)

            expect(subject.model).to eq('textembedding-gecko-001')

            expect(subject.value.size).to eq(768)
            expect(subject.value).to all(be_a(Float))

            expect(subject.values.size).to eq(1)

            expect(subject.prompt_tokens).to eq(nil)
            expect(subject.completion_tokens).to eq(nil)
            expect(subject.total_tokens).to eq(nil)
          end
        end

        context 'with custom model' do
          let(:input) { 'Hello' }
          let(:model) { 'textembedding-gecko-multilingual' }
          let(:cassette) { "google_palm/language/embed_single_input_#{model}" }

          subject { instance.embed(input, model:) }

          it 'returns an array with one embeddings' do
            VCR.use_cassette(cassette) do
              expect do
                subject
              end.to raise_error(GenAI::ApiError,
                                  %r{GooglePalm API error: models/textembedding-gecko-multilingual is not found for API version v1beta2})
            end
          end
        end
      end

      context 'with array input' do
        let(:input) { %w[Hello Cześć] }
        let(:cassette) { 'google_palm/language/embed_multiple_inputs' }

        it 'returns an array with two embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(GenAI::Result)

            expect(subject.values[0]).to all(be_a(Float))
            expect(subject.values[0].size).to eq(768)

            expect(subject.values[1]).to all(be_a(Float))
            expect(subject.values[1].size).to eq(768)
          end
        end
      end

      context 'invalid input' do
        let(:input) { {} }
        let(:cassette) { 'google_palm/language/embed_invalid_input' }

        it 'raises an GenAI::ApiError error' do
          VCR.use_cassette(cassette) do
            expect { subject }.to raise_error(GenAI::ApiError, /GooglePalm API error: Invalid value \(text\)/)
          end
        end
      end
    end
  end
end
