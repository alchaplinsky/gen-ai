# frozen_string_literal: true

require 'faraday'
require 'pry'

module GenAI
  class Language
    class Gemini < Base
      include GenAI::Api::Format::Gemini

      COMPLETION_MODEL = 'gemini-pro'

      def initialize(token:, options: {})
        depends_on 'gemini-ai'

        @client = ::Gemini.new(
          credentials: {
            service: 'generative-language-api',
            api_key: token
          },
          options: { model: model(options), server_sent_events: true }
        )
      end

      def complete(prompt, options = {}); end

      def chat(messages, options = {}, &block)
        response = @client.stream_generate_content({
          contents: format_messages(messages),
          generationConfig: options.except(:model)
}) do |chunk|
          yield chunk if block_given?
        end

        build_result(model: model(options), raw: response, parsed: extract_completions(response))
      end

      private

      def model(options)
        options[:model] || COMPLETION_MODEL
      end
    end
  end
end
