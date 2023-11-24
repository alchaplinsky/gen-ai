# frozen_string_literal: true

require 'openai'

RSpec.describe GenAI::Image do
  describe 'Stability AI' do
    describe '#upscale' do
      let(:provider) { :stability_ai }
      let(:instance) { described_class.new(provider, token) }
      let(:token) { ENV['API_ACCESS_TOKEN'] || 'FAKE_TOKEN' }

      let(:cassette) { 'stability_ai/image/upscale_default' }
      let(:fixture_file) { 'lighthouse_upscaled' }
      let(:original_image) { './spec/fixtures/images/lighthouse.png' }
      let(:image_base64) { Base64.encode64(File.read("spec/fixtures/images/#{fixture_file}.png")) }

      subject { instance.upscale original_image, size: '512x512' }

      it 'creates upscaled version of an image' do
        VCR.use_cassette(cassette) do
          expect(subject).to be_a(GenAI::Result)
          expect(subject.provider).to eq(:stability_ai)

          expect(subject.model).to eq('stable-diffusion-x4-latent-upscaler')

          expect(subject.value).to be_a(String)
          expect(Base64.encode64(subject.value)).to eq(image_base64)

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
          subject { instance.upscale(original_image) }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/generation/stable-diffusion-x4-latent-upscaler/image-to-image/upscale', {
                image: File.binread(original_image),
                width: 256
              },
              multipart: true
            )
          end
        end

        context 'with additional options' do
          subject { instance.upscale(original_image, size: '512x512') }

          it 'passes options to the client' do
            subject

            expect(client).to have_received(:post).with(
              '/v1/generation/stable-diffusion-x4-latent-upscaler/image-to-image/upscale', {
                image: File.binread(original_image),
                width: 512
              }, multipart: true
            )
          end
        end
      end
    end
  end
end
