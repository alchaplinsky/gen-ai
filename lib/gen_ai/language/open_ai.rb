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
          client.chat(parameters: chat_parameters(prompt, options))
        end

        response['choices'].map { |completion| completion['message'] }
      end

      private

      def chat_parameters(prompt, options)
        {
          messages: [{ role: DEFAULT_ROLE, content: prompt }],
          model: options.fetch(:model, COMPLETION_MODEL)
        }
      end
    end
  end
end
