# frozen_string_literal: true

module GenAI
  class Image
    class OpenAI < Base
      DEFAULT_SIZE = '256x256'
      RESPONSE_FORMAT = 'b64_json'

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end

      def generate(prompt, options = {})
        parameters = build_generation_options(prompt, options)

        response = handle_errors { @client.images.generate(parameters: parameters) }

        build_result(
          raw: response,
          model: 'dall-e',
          parsed: response['data'].map { |datum| datum[RESPONSE_FORMAT] }
        )
      end

      def variations(image, options = {})
        parameters = build_variations_options(image, options)

        response = handle_errors { @client.images.variations(parameters: parameters) }

        build_result(
          raw: response,
          model: 'dall-e',
          parsed: response['data'].map { |datum| datum[RESPONSE_FORMAT] }
        )
      end

      private

      def build_generation_options(prompt, options)
        {
          prompt: prompt,
          size: options.delete(:size) || DEFAULT_SIZE,
          response_format: options.delete(:response_format) || RESPONSE_FORMAT
        }.merge(options)
      end

      def build_variations_options(image, options)
        {
          image: image,
          size: options.delete(:size) || DEFAULT_SIZE,
          response_format: options.delete(:response_format) || RESPONSE_FORMAT
        }.merge(options)
      end
    end
  end
end
