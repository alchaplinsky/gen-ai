# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Image do
  describe '#edit' do
    let(:provider) { :open_ai }
    let(:instance) { described_class.new(provider, token) }
    let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

    let(:cassette) { 'openai/image/edit_clean_llama_icon' }
    let(:fixture_file) { 'llama_edited' }
    let(:image_base64) { Base64.encode64(File.read("spec/fixtures/images/#{fixture_file}.png")).gsub("\n", '') }
    let(:original_image) { './spec/fixtures/images/llama_rgba.png' }
    let(:prompt) { 'On a yellow background' }

    subject { instance.edit(original_image, prompt) }

    it 'generates an image' do
      VCR.use_cassette(cassette) do
        expect(subject).to be_a(GenAI::Result)
        expect(subject.provider).to eq(:open_ai)

        expect(subject.model).to eq('dall-e')

        expect(subject.value).to be_a(String)
        expect(subject.value).to eq(image_base64)

        expect(subject.prompt_tokens).to eq(nil)
        expect(subject.completion_tokens).to eq(nil)
        expect(subject.total_tokens).to eq(nil)
      end
    end

    context 'with options' do
      let(:client) { double('OpenAI::Client') }
      let(:images) { double('OpenAI::Client::Images') }

      before do
        allow(OpenAI::Client).to receive(:new).and_return(client)
        allow(images).to receive(:edit).and_return({ 'data' => [] })
        allow(client).to receive(:images).and_return(images)
      end

      context 'with default options' do
        subject { instance.edit(original_image, prompt) }

        it 'passes options to the client' do
          subject

          expect(images).to have_received(:edit).with({
            parameters: {
              image: original_image,
              prompt: prompt,
              response_format: 'b64_json',
              size: '256x256'
            }
          })
        end
      end

      context 'with default options' do
        subject { instance.edit(original_image, prompt, size: '512x512', response_format: 'url', n: 2) }

        it 'passes options to the client' do
          subject

          expect(images).to have_received(:edit).with({
            parameters: {
              n: 2,
              image: original_image,
              prompt: prompt,
              response_format: 'url',
              size: '512x512'
            }
          })
        end
      end
    end
  end
end
