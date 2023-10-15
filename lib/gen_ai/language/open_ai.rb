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
        response = handle_errors do
          client.embeddings(parameters: { input: input, model: model || EMBEDDING_MODEL })
        end

        response['data'].map { |embedding| embedding['embedding'] }
      end

      def complete(prompt, options: {})
        response = handle_errors do
          client.chat(parameters: build_completion_options(prompt, options))
        end

        response['choices'].map { |completion| completion['message'] }
      end

      def chat(message, context: nil, history: [], examples: [], options: {})
        response = handle_errors do
          client.chat(parameters: build_chat_options(message, context, history, examples, options))
        end

        response['choices'].map { |completion| completion['message'] }
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
    end
  end
end
