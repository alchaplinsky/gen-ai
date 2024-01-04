# frozen_string_literal: true

module GenAI
  class Chat
    class Anthropic < Base
      SYSTEM_ROLE = 'system'

      private

      def build_history(messages, context, examples)
        @context = context
        history = []
        history.concat(examples)
        history.concat(messages)
        history
      end

      def role(message)
        message[:role]
      end

      def transform_message(message)
        message
      end

      def append_to_message(message)
        @history.last[:content] = "#{@history.last[:content]}\n#{message}"
      end

      def chat_options
        { system: @context }
      end
    end
  end
end
