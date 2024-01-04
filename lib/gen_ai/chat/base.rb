# frozen_string_literal: true

module GenAI
  class Chat
    class Base < GenAI::Base
      USER_ROLE = 'user'
      ASSISTANT_ROLE = 'assistant'

      attr_reader :history

      def initialize(provider:, token:, options: {})
        @history = []
        @model = GenAI::Language.new(provider, token, options: options)
      end

      def start(history: [], context: nil, examples: [])
        @history = build_history(history.map(&:deep_symbolize_keys!), context, examples.map(&:deep_symbolize_keys!))
      end

      def message(message, options = {})
        if @history.size == 1 && @history.first[:role] != 'system'
          append_to_message(message)
        else
          append_to_history({ role: USER_ROLE, content: message })
        end

        response = @model.chat(@history.dup, chat_options.merge(options).compact)
        append_to_history({ role: ASSISTANT_ROLE, content: response.value })
        response
      end

      private

      def append_to_history(message)
        @history << transform_message(message)
      end

      def chat_options
        {}
      end
    end
  end
end
