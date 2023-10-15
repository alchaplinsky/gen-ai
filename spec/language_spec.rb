# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#embed' do
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    subject { instance.embed(input) }

    context 'with openai provider' do
      let(:provider) { :openai }

      context 'with single string input' do
        let(:input) { 'Hello' }
        let(:cassette) { 'openai/embed/single_input' }

        it 'returns an array with one embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first.size).to eq(1536)
            expect(subject.first).to all(be_a(Float))
          end
        end
      end

      context 'with array input' do
        let(:input) { %w[Hello Cześć] }
        let(:cassette) { 'openai/embed/multiple_input' }

        it 'returns an array with two embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to all(be_a(Float))
            expect(subject.first.size).to eq(1536)
            expect(subject.last).to all(be_a(Float))
            expect(subject.last.size).to eq(1536)
          end
        end
      end

      context 'invalid input' do
        let(:input) { nil }
        let(:cassette) { 'openai/embed/invalid_input' }

        it 'raises an API error' do
          VCR.use_cassette(cassette) do
            expect { subject }.to raise_error(GenAI::ApiError, /Please submit an `input`/)
          end
        end
      end
    end

    context 'with google_palm provider' do
      let(:provider) { :google_palm }

      context 'with singe string input' do
        let(:input) { 'Hello' }
        let(:cassette) { 'google/embed/single_input' }

        it 'returns an array with one embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first.size).to eq(768)
            expect(subject.first).to all(be_a(Float))
          end
        end
      end

      context 'with array input' do
        let(:input) { %w[Hello Cześć] }
        let(:cassette) { 'google/embed/multiple_input' }

        it 'returns an array with two embeddings' do
          VCR.use_cassette(cassette) do
            expect(subject).to be_a(Array)
            expect(subject.first).to all(be_a(Float))
            expect(subject.first.size).to eq(768)
            expect(subject.last).to all(be_a(Float))
            expect(subject.last.size).to eq(768)
          end
        end
      end

      context 'invalid input' do
        let(:input) { {} }
        let(:cassette) { 'google/embed/invalid_input' }

        it 'raises an API error' do
          VCR.use_cassette(cassette) do
            expect { subject }.to raise_error(GenAI::ApiError, /GooglePalm API error: Invalid value (text)/)
          end
        end
      end
    end

    context 'with unsupported provider' do
      # TODO: add tests
    end
  end
end
