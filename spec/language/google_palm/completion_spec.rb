# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#complete' do
    let(:provider) { :google_palm }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
    let(:instance) { described_class.new(provider, token) }
    let(:cassette) { 'google_palm/language/complete_default_prompt' }

    subject { instance.complete('Hello') }

    it 'returns completions' do
      VCR.use_cassette(cassette) do
        expect(subject).to be_a(GenAI::Result)
        expect(subject.provider).to eq(:google_palm)
        expect(subject.model).to eq('text-bison-001')

        expect(subject.value).to eq(', world!')
        expect(subject.values).to eq([', world!'])

        expect(subject.prompt_tokens).to eq(nil)
        expect(subject.completion_tokens).to eq(nil)
        expect(subject.total_tokens).to eq(nil)
      end
    end

    context 'with options' do
      let(:client) { double('GooglePalmApi::Client') }

      before do
        allow(GooglePalmApi::Client).to receive(:new).and_return(client)
        allow(client).to receive(:generate_text).and_return({ 'candidates' => [] })
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
end
