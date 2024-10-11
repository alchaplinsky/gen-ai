# frozen_string_literal: true

require 'base64'

module GenAI
  class Image
    class OpenAI < Base
      DEFAULT_SIZE = '256x256'
      DEFAULT_MODEL = 'dall-e-3'
      RESPONSE_FORMAT = 'b64_json'

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end

      def generate(prompt, options = {})
        parameters = build_generation_options(prompt, options)

        response = handle_errors { @client.images.generate(parameters:) }

        build_result(
          raw: response,
          model: parameters[:model],
          parsed: parse_response_data(response['data'])
        )
      end

      def variations(image, options = {})
        parameters = build_variations_options(image, options)

        response = handle_errors { @client.images.variations(parameters:) }

        build_result(
          raw: response,
          model: parameters[:model],
          parsed: parse_response_data(response['data'])
        )
      end

      def edit(image, prompt, options = {})
        parameters = build_edit_options(image, prompt, options)

        response = handle_errors { @client.images.edit(parameters:) }

        build_result(
          raw: response,
          model: parameters[:model],
          parsed: parse_response_data(response['data'])
        )
      end

      private

      def build_generation_options(prompt, options)
        {
          prompt:,
          size: options.delete(:size) || DEFAULT_SIZE,
          model: options.delete(:model) || DEFAULT_MODEL,
          response_format: options.delete(:response_format) || RESPONSE_FORMAT
        }.merge(options)
      end

      def build_variations_options(image, options)
        {
          image:,
          size: options.delete(:size) || DEFAULT_SIZE,
          model: 'dall-e-2', # variation is only available on dall-e-2
          response_format: options.delete(:response_format) || RESPONSE_FORMAT
        }.merge(options)
      end

      def build_edit_options(image, prompt, options)
        {
          image:,
          prompt:,
          size: options.delete(:size) || DEFAULT_SIZE,
          model: 'dall-e-2', # edit is only available on dall-e-2
          response_format: options.delete(:response_format) || RESPONSE_FORMAT
        }.merge(options)
      end

      def parse_response_data(data)
        data.map { |datum| Base64.decode64(datum[RESPONSE_FORMAT]) }
      end
    end
  end
end
