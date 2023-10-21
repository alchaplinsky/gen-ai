# frozen_string_literal: true

module GenAI
  class Language
    class OpenAI < Base
      EMBEDDING_MODEL = 'text-embedding-ada-002'
      COMPLETION_MODEL = 'gpt-3.5-turbo'

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end

      def embed(input, model: nil)
        parameters = { input: input, model: model || EMBEDDING_MODEL }

        response = handle_errors { client.embeddings(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_embeddings(response))
      end

      def complete(prompt, options: {})
        parameters = build_completion_options(prompt, options)

        response = handle_errors { client.chat(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_completions(response))
      end

      def chat(message, context: nil, history: [], examples: [], options: {})
        parameters = build_chat_options(message, context, history, examples, options)

        response = handle_errors { client.chat(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_completions(response))
      end

      private

      def build_chat_options(message, context, history, examples, options)
        messages = []
        messages.concat(examples)
        messages.concat(history)

        messages.prepend({ role: 'system', content: context }) if context

        messages.append({ role: DEFAULT_ROLE, content: message })

        {
          messages: messages,
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)
      end

      def build_completion_options(prompt, options)
        {
          messages: [{ role: DEFAULT_ROLE, content: prompt }],
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)
      end

      def extract_embeddings(response)
        response['data'].map { |datum| datum['embedding'] }
      end

      def extract_completions(response)
        response['choices'].map { |choice| choice.dig('message', 'content') }
      end
    end
  end
end
