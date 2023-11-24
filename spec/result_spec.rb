# frozen_string_literal: true

RSpec.describe GenAI::Result do
  subject do
    described_class.new(provider: :open_ai, model: 'gpt-3.5-turbo', raw: {}, values: ['The capital of Turkey is Ankara.'])
  end

  describe '#value' do
    it 'returns raw value' do
      expect(subject.value).to eq('The capital of Turkey is Ankara.')
    end

    it 'returns base64 value' do
      expect(subject.value(:base64)).to eq("VGhlIGNhcGl0YWwgb2YgVHVya2V5IGlzIEFua2FyYS4=\n")
    end
  end

  describe '#prompt_tokens' do
    it 'returns prompt tokens' do
      expect(subject.prompt_tokens).to eq(nil)
    end
  end

  describe '#completion_tokens' do
    it 'returns completion tokens' do
      expect(subject.completion_tokens).to eq(nil)
    end
  end

  describe '#total_tokens' do
    it 'returns total tokens' do
      expect(subject.total_tokens).to eq(nil)
    end
  end
end
