# frozen_string_literal: true

require 'faraday'
require 'pry'
module GenAI
  class Language
    class Gemini < Base
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

      def extract_completions(response)
        response['candidates'].map { |candidate| candidate.dig('content', 'parts', 0, 'text') }
      end
    end
  end
end
