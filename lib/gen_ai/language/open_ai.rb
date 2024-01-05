# frozen_string_literal: true

module GenAI
  class Language
    class OpenAI < Base
      include GenAI::Api::Format::OpenAI

      EMBEDDING_MODEL = 'text-embedding-ada-002'
      COMPLETION_MODEL = 'gpt-3.5-turbo-1106'

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end

      def embed(input, model: nil)
        parameters = { input: input, model: model || EMBEDDING_MODEL }

        response = handle_errors { client.embeddings(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_embeddings(response))
      end

      def complete(prompt, options = {})
        parameters = build_completion_options(prompt, options)

        response = handle_errors { client.chat(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_completions(response))
      end

      def chat(messages, options = {})
        parameters = {
          messages: messages.map(&:deep_symbolize_keys),
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)

        response = handle_errors { client.chat(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_completions(response))
      end

      private

      def build_completion_options(prompt, options)
        {
          messages: [{ role: DEFAULT_ROLE, content: prompt }],
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)
      end
    end
  end
end
