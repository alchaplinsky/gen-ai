# frozen_string_literal: true

require 'faraday'

module GenAI
  class Image
    class StabilityAI < Base
      DEFAULT_SIZE = '256x256'
      API_BASE_URL = 'https://api.stability.ai'
      DEFAULT_MODEL = 'stable-diffusion-xl-beta-v2-2-2'

      def initialize(token:, options: {})
        build_client(token)
      end

      def generate(prompt, options = {})
        model = options[:model] || DEFAULT_MODEL

        response = client.post "/v1/generation/#{model}/text-to-image", build_generation_body(prompt, options)

        build_result(
          raw: response,
          model: model,
          parsed: response['artifacts'].map { |artifact| artifact['base64'] }
        )
      end

      private

      def build_client(token)
        @client = GenAI::Api::Client.new(url: API_BASE_URL, token: token)
      end

      def build_generation_body(prompt, options)
        w, h = size(options)

        {
          text_prompts: [{ text: prompt }],
          height: h,
          width: w
        }.merge(options)
      end

      def size(options)
        size = options.delete(:size) || DEFAULT_SIZE
        size.split('x').map(&:to_i)
      end
    end
  end
end
