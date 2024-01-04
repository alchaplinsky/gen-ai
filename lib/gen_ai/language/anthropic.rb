# frozen_string_literal: true

require 'faraday'

module GenAI
  class Language
    class Anthropic < Base
      include GenAI::Api::Format::Anthropic

      BASE_API_URL = 'https://api.anthropic.com'
      ANTHROPIC_VERSION = '2023-06-01'
      ANTHROPIC_BETA = 'messages-2023-12-15'
      COMPLETION_MODEL = 'claude-2.1'
      DEFAULT_MAX_TOKENS = 1024

      def initialize(token:, options: {})
        @token = token
        build_client(token)
      end

      def complete(prompt, options = {})
        response = client.post '/v1/complete', {
          prompt: "\n\nHuman: #{prompt}\n\nAssistant:",
          model: options.delete(:model) || COMPLETION_MODEL,
          max_tokens_to_sample: options.delete(:max_tokens_to_sample) || DEFAULT_MAX_TOKENS
        }.merge(options)

        build_result(model: COMPLETION_MODEL, raw: response, parsed: extract_completions(response))
      end

      def chat(messages, options = {})
        response = client.post '/v1/messages', {
          messages: format_messages(messages),
          model: options.delete(:model) || COMPLETION_MODEL,
          max_tokens: options.delete(:max_tokens) || DEFAULT_MAX_TOKENS
        }.merge(options)

        build_result(model: COMPLETION_MODEL, raw: response, parsed: extract_completions(response))
      end

      private

      def build_client(token)
        @client = GenAI::Api::Client.new(url: BASE_API_URL, token: nil, headers: {
          'anthropic-beta' => ANTHROPIC_BETA,
          'anthropic-version' => ANTHROPIC_VERSION,
          'x-api-key' => token
        })
      end
    end
  end
end
