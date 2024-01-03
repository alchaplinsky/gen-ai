# frozen_string_literal: true

require 'faraday'
require 'pry'
module GenAI
  class Language
    class Gemini < Base
      include GenAI::Api::Format::Gemini

      BASE_API_URL = 'https://generativelanguage.googleapis.com'

      def initialize(token:, options: {})
        @token = token
        build_client(token)
      end

      def complete(prompt, options = {}); end

      def chat(messages, options = {})
        response = client.post "/v1beta/models/gemini-pro:generateContent?key=#{@token}", {
          contents: messages.map(&:deep_symbolize_keys!),
          generationConfig: options
        }

        build_result(model: 'gemini-pro', raw: response, parsed: extract_completions(response))
      end

      private

      def build_client(token)
        @client = GenAI::Api::Client.new(url: BASE_API_URL, token: nil)
      end
    end
  end
end
