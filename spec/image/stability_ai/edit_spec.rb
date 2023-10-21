# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Image do
  describe 'Stability AI' do
    describe '#edit' do
      let(:provider) { :stability_ai }
      let(:instance) { described_class.new(provider, token) }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

      let(:cassette) { 'stability_ai/image/edit_lighthouse' }
      let(:fixture_file) { 'lighthouse_edited' }
      let(:image_base64) { Base64.encode64(File.read("spec/fixtures/images/#{fixture_file}.png")).gsub("\n", '') }
      let(:original_image) { './spec/fixtures/images/lighthouse.png' }
      let(:prompt) { 'Blue water' }

      subject { instance.edit(original_image, prompt) }

      it 'generates an image' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)
          expect(subject.provider).to eq(:stability_ai)

          expect(subject.model).to eq('stable-diffusion-xl-beta-v2-2-2')

          expect(subject.value).to be_a(String)
          expect(subject.value).to eq(image_base64)

          expect(subject.prompt_tokens).to eq(nil)
          expect(subject.completion_tokens).to eq(nil)
          expect(subject.total_tokens).to eq(nil)
        end
      end

      context 'with options' do
        let(:client) { double('GenAI::Api::Client') }

        before do
          allow(GenAI::Api::Client).to receive(:new).and_return(client)
          allow(client).to receive(:post).and_return({ 'artifacts' => [] })
        end

        context 'with default options' do
          subject { instance.edit(original_image, prompt) }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/generation/stable-diffusion-xl-beta-v2-2-2/image-to-image',
              {
                init_image: File.binread(original_image),
                'text_prompts[0][text]' => 'Blue water',
                'text_prompts[0][weight]' => 1.0
              },
               multipart: true
            )
          end
        end

        context 'with additional options' do
          subject { instance.edit(original_image, prompt, samples: 2, style_preset: 'analog-film') }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/generation/stable-diffusion-xl-beta-v2-2-2/image-to-image',
              {
                init_image: File.binread(original_image),
                'text_prompts[0][text]' => 'Blue water',
                'text_prompts[0][weight]' => 1.0,
                samples: 2,
                style_preset: 'analog-film'
              },
               multipart: true
            )
          end
        end
      end
    end
  end
end
