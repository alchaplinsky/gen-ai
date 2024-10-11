# frozen_string_literal: true

require 'faraday'

module GenAI
  class Image
    class StabilityAI < Base
      DEFAULT_SIZE = '256x256'
      API_BASE_URL = 'https://api.stability.ai'
      DEFAULT_MODEL = 'stable-diffusion-xl-beta-v2-2-2'
      UPSCALE_MODEL = 'stable-diffusion-x4-latent-upscaler'

      def initialize(token:, options: {})
        build_client(token)
      end

      def generate(prompt, options = {})
        model = options[:model] || DEFAULT_MODEL
        url = "/v1/generation/#{model}/text-to-image"

        response = client.post url, build_generation_body(prompt, options)

        build_result(
          raw: response,
          model:,
          parsed: parse_response_data(response['artifacts'])
        )
      end

      def edit(image, prompt, options = {})
        model = options[:model] || DEFAULT_MODEL
        url = "/v1/generation/#{model}/image-to-image"

        response = client.post url, build_edit_body(image, prompt, options), multipart: true

        build_result(
          raw: response,
          model:,
          parsed: parse_response_data(response['artifacts'])
        )
      end

      def upscale(image, options = {})
        model = options[:model] || UPSCALE_MODEL
        url = "/v1/generation/#{model}/image-to-image/upscale"

        response = client.post url, build_upscale_body(image, options), multipart: true

        build_result(
          raw: response,
          model:,
          parsed: parse_response_data(response['artifacts'])
        )
      end

      private

      def build_client(token)
        @client = GenAI::Api::Client.new(url: API_BASE_URL, token:)
      end

      def build_generation_body(prompt, options)
        w, h = size(options)

        {
          text_prompts: [{ text: prompt }],
          height: h,
          width: w
        }.merge(options)
      end

      def build_edit_body(image, prompt, options)
        params = {
          init_image: File.binread(image),
          'text_prompts[0][text]' => prompt,
          'text_prompts[0][weight]' => 1.0
        }
        params.merge!(mask: File.binread(options.delete(:mask))) if options[:mask]
        params.merge(options)
      end

      def build_upscale_body(image, options)
        w, = size(options)
        {
          image: File.binread(image),
          width: w
        }.merge(options)
      end

      def size(options)
        size = options.delete(:size) || DEFAULT_SIZE
        size.split('x').map(&:to_i)
      end

      def parse_response_data(data)
        data.map { |artifact| Base64.decode64(artifact['base64']) }
      end
    end
  end
end
