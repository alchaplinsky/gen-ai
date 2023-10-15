# frozen_string_literal: true

module GenAI
  class Language
    class GooglePalm < Base
      COMPLETION_MODEL = 'chat-bison-001'.freeze

      def initialize(token:, options: {})
        depends_on 'google_palm_api'

        @client = ::GooglePalmApi::Client.new(api_key: token)
      end

      def embedding(input, options: {})
        # TODO: Handle array input by calling the API multiple times
        response = handle_errors do
          response = client.embed(text: input)
        end

        [response.dig('embedding', 'value')]
      end

      def completion(prompt, options: {})
        response = handle_errors do
          client.generate_chat_message **chat_parameters(prompt, options)
        end

        response['candidates']
      end

      private

      def chat_parameters(prompt, options)
        {
          model: COMPLETION_MODEL,
          messages: [{ author: DEFAULT_ROLE, content: prompt }]
        }
      end
    end
  end
end
