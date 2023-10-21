# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Image do
  describe 'Stability AI' do
    describe '#generate' do
      let(:provider) { :stability_ai }
      let(:instance) { described_class.new(provider, token) }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

      let(:cassette) { 'stability_ai/image/generate_default_prompt' }
      let(:fixture_file) { 'lighthouse' }
      let(:image_base64) { Base64.encode64(File.read("spec/fixtures/images/#{fixture_file}.png")).gsub("\n", '') }
      let(:prompt) { 'Lighthouse on the shore' }

      subject { instance.generate(prompt) }

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
          subject { instance.generate(prompt) }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with('/v1/generation/stable-diffusion-xl-beta-v2-2-2/text-to-image', {
              text_prompts: [{ text: 'Lighthouse on the shore' }],
              width: 256,
              height: 256
            })
          end
        end

        context 'with default options' do
          subject { instance.generate(prompt, size: '512x512', samples: 2, style_preset: 'photographic') }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with('/v1/generation/stable-diffusion-xl-beta-v2-2-2/text-to-image', {
              text_prompts: [{ text: 'Lighthouse on the shore' }],
              samples: 2,
              style_preset: 'photographic',
              width: 512,
              height: 512
            })
          end
        end
      end
    end
  end
end
