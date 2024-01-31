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
            api_key: token,
            version: 'v1beta'
          },
          options: { model: model(options) }
        )
      end

      def complete(prompt, options = {}); end

      def chat(messages, options = {}, &block)
        response = if block_given?
                     @client.stream_generate_content(
                       generate_options(messages, options.mege(server_sent_events: true)), &block
                     )
                   else
                     @client.generate_content(generate_options(messages, options))
                   end

        build_result(model: model(options), raw: response, parsed: extract_completions(response))
      end

      private

      def generate_options(messages, options)
        {
          contents: format_messages(messages),
          generationConfig: options.except(:model)
        }
      end

      def model(options)
        options[:model] || COMPLETION_MODEL
      end
    end
  end
end
