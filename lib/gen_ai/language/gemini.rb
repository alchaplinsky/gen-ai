# frozen_string_literal: true

require 'faraday'

module GenAI
  class Language
    class Gemini < Base
      BASE_API_URL = 'https://generativelanguage.googleapis.com'

      def initialize(token:, options: {})
        @token = token
        build_client(token)
      end

      def complete(prompt, options = {})
        
      end

      def chat(message, context: nil, history: [], examples: [], options: {})
        client.post "/v1beta/models/gemini-pro:generateContent?key=#{@token}", build_chat_body(message)
      end

      private

      def build_chat_body(message)
        { contents: [{parts: [{text: message}]}]}
      end

      def build_client(token)
        @client = GenAI::Api::Client.new(url: BASE_API_URL, token: nil)
      end
    end
  end
end
