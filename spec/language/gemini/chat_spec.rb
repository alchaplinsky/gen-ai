# frozen_string_literal: true

RSpec.describe GenAI::Language do
  describe '#chat' do
    let(:provider) { :gemini }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }
    let(:instance) { described_class.new(provider, token) }
    let(:cassette) { 'gemini/language/chat_default_message' }
    let(:messages) { [{ role: 'user', parts: [{text: prompt }]}] }
    let(:prompt) { 'What is the capital of Turkey?' }

    subject { instance.chat(messages) }

    it 'returns chat response' do
      VCR.use_cassette(cassette) do
        expect(subject).to be_a(GenAI::Result)

        expect(subject.provider).to eq(:gemini)
        expect(subject.model).to eq('gemini-pro')

        expect(subject.value).to match('Ankara')
        expect(subject.values).to match([a_string_matching('Ankara')])

        expect(subject.prompt_tokens).to eq(nil)
        expect(subject.completion_tokens).to eq(nil)
        expect(subject.total_tokens).to eq(nil)
      end
    end

    context 'with custom options' do
      let(:prompt) { 'Hi, can you help me?' }
      let(:cassette) { 'gemini/language/chat_message_with_options' }

      subject do
        instance.chat(messages, { temperature: 0, max_output_tokens: 14 })
      end

      it 'responds with completions according to passed options' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)
          expect(subject.values).to eq(['Sure, I can help you with a variety of tasks and questions.'])
        end
      end
    end
  end
end
