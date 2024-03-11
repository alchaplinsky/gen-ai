# frozen_string_literal: true

require 'faraday'

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
          options: { model: model(options) }
        )
      end

      def complete(prompt, options = {}); end

      def chat(messages, options = {}, &block)
        if block_given?
          response = @client.stream_generate_content(
            generate_options(messages, options), server_sent_events: true, &chunk_process_block(block)
          )
          build_result(model: model(options), raw: response.first, parsed: extract_completions(response).flatten)
        else
          response = @client.generate_content(generate_options(messages, options))
          build_result(model: model(options), raw: response, parsed: extract_completions(response))
        end
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

      def chunk_process_block(block)
        proc do |data|
          chunk = build_chunk(chunk_params_from_streaming(data))

          block.call chunk
        end
      end
    end
  end
end
